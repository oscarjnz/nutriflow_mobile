# Fasting timer - diseño

Fecha: 2026-07-31
Estado: aprobado por Oscar, pendiente de plan de implementacion

## Contexto

Fase 3 (CLAUDE.md seccion 8) tiene pendientes: fasting timer, edicion de foods, favorites/recipes. Weight logs + el cache local de lectura ya estan hechos (2026-07-30). Esta sesion cubre el fasting timer, la siguiente feature vacia de Fase 3.

Decisiones de alcance confirmadas con Oscar:
- Rachas (`user_streaks`) quedan fuera de este corte. No existe logica de calculo de streaks en ningun lado del producto (ni web ni mobile) - es su propia mini-feature, se diseña aparte cuando toque.
- Se permite terminar un ayuno activo normalmente, y tambien cancelarlo (soft delete) si se inicio por error.
- Punto de entrada: icono en el AppBar de `WeightLogScreen`, mismo patron que el icono de escanear codigo de barras en `LoggingScreen` (`features/logging/logging_screen.dart` -> `barcode_scan_screen.dart`). Sin cambios a `FloatingNavBar`.

## Esquema real (fuente de verdad: repo `nutriflow`)

Tabla `public.fasting_sessions` (`nutriflow/supabase/migrations/20260613_0007_body_and_fasting.sql:17-36`):

```
id              uuid primary key          -- sin default, se genera client-side
user_id         uuid not null             -- FK a public.users(id)
start_at        timestamptz not null
end_at          timestamptz               -- null = ayuno en curso
target_hours    integer not null          -- check > 0 and <= 72
protocol        text not null             -- check in ('12:12','14:10','16:8','18:6','20:4','custom')
notes           text                      -- opcional
created_at      timestamptz not null default now()
deleted_at      timestamptz               -- soft delete (cancelar)
                                           -- check (end_at is null or end_at > start_at)
```

Constraints relevantes:
- `fasting_active_per_user`: unique index parcial `(user_id) where end_at is null and deleted_at is null` - a nivel de base de datos, un usuario no puede tener dos ayunos activos a la vez. Es la fuente de verdad; el cliente no duplica esta regla, solo maneja el error si la insert la viola.
- `fasting_user_start_idx`: index para el historial (`user_id, start_at desc where deleted_at is null`).

RLS (`nutriflow/supabase/migrations/20260613_0011_clerk_rls.sql`) exige `user_id = app_user_id()` en select/insert/update/delete, `to authenticated` (mismo patron que `weight_logs`). No hay endpoint REST (CRUD simple, CLAUDE.md seccion 6): lectura/escritura directa a Supabase.

La pagina web de ayuno (`nutriflow/src/app/(dashboard)/fasting/page.tsx`) es un placeholder ("Proximamente", Sprint 5) - no hay UI de referencia que portar, el diseño de abajo es nuevo.

## Modelo

`models/fasting_session.dart` (`@freezed`), mirror 1:1 de las columnas de arriba. `protocol` como `String` (no enum Dart) para no duplicar la validacion del `check` de Postgres - los valores validos se usan tal cual como los strings de la tabla, tanto al construir los chips de seleccion como al leer.

## Repository (`core/supabase/fasting_sessions_repository.dart`)

Mismo patron que `WeightLogsRepository` (`app_user_id()` via RPC, `uuid` v4 client-side, `cachedFetch` para lecturas):

- `fetchActive()` -> `CachedValue<FastingSession?>`: `select().isFilter('end_at', null).isFilter('deleted_at', null).maybeSingle()`, envuelto en `cachedFetch` (key `fasting_active`).
- `fetchHistory({int limit = 30})` -> `CachedValue<List<FastingSession>>`: `select().isFilter('deleted_at', null).not('end_at', 'is', null).order('start_at', ascending: false).limit(limit)`, envuelto en `cachedFetch` (key `fasting_history`). Solo incluye sesiones terminadas (la activa, si existe, se muestra aparte via `fetchActive`).
- `startFast({required String protocol, required int targetHours, String? notes})`: resuelve `user_id` via RPC, genera `id`, inserta con `start_at = now()`. Si Supabase devuelve el error de unique-violation de `fasting_active_per_user` (Postgres code `23505`), se traduce a una excepcion con mensaje curado ("Ya tienes un ayuno en curso") en vez de dejar pasar el mensaje crudo de Postgres - mismo principio que el resto de errores de escritura del repo (seccion 9, nunca silenciar, siempre curar el mensaje al usuario).
- `endFast(String id)`: `update({'end_at': now()}).eq('id', id)`.
- `cancelFast(String id)`: `update({'deleted_at': now()}).eq('id', id)` (soft delete).

## Providers (`core/supabase/providers.dart`)

`activeFastingSessionProvider` y `recentFastingSessionsProvider`, ambos `FutureProvider.autoDispose`, misma forma que `recentWeightLogsProvider`. `startFast`/`endFast`/`cancelFast` invalidan ambos providers al terminar con exito (igual que `logWeight` invalida `recentWeightLogsProvider` hoy).

## Pantalla (`features/fasting/fasting_screen.dart`)

Ruta `/fasting` (`app/router.dart`), alcanzable desde un icono `LucideIcons.timer` en el AppBar de `WeightLogScreen`.

**Con ayuno activo** (`activeFastingSessionProvider` con valor no nulo):
- Card grande (mismo lenguaje visual que `HeroCard`) con: badge del protocolo, tiempo transcurrido en vivo ("14h 32m") calculado como `DateTime.now().difference(session.startAt)`, subtitulo "de {targetHours}h", barra de progreso (`transcurrido / target`, clamped a 1.0 si se pasa de la meta).
- El tiempo transcurrido se refresca con un `Timer.periodic(Duration(seconds: 1))` local al `State`, arrancado en `initState`/cuando `activeFastingSessionProvider` pasa a tener un valor activo, cancelado en `dispose`. Actualiza solo ese texto (`setState` acotado, no reconsulta el provider en cada tick).
- Botones "Terminar ayuno" (`endFast`) y "Cancelar" (`cancelFast`, con confirmacion simple ya que borra el registro).

**Sin ayuno activo:**
- Selector de protocolo: chips `12:12 / 14:10 / 16:8 / 18:6 / 20:4 / Personalizado`. Cada chip preset trae su `targetHours` implicito (12/14/16/18/20). "Personalizado" habilita un campo numerico de horas (1-72, validacion client-side simple antes de habilitar "Empezar ayuno" - refleja el `check` de la tabla, no lo reemplaza).
- Campo de notas opcional.
- Boton "Empezar ayuno" (`startFast`).

**Historial** (debajo, ambos estados): lista de `recentFastingSessionsProvider` (protocolo, duracion real `end_at - start_at` formateada, fecha), mismo estilo de card que el historial de `WeightLogScreen`.

**Offline:** mismo banner "Sin conexion: mostrando los ultimos datos guardados." que Dashboard/Peso, si `fromCache` es true en `activeFastingSessionProvider` o `recentFastingSessionsProvider`.

## Manejo de errores

- Lecturas: caen al cache local (`cachedFetch`), banner no bloqueante, error real siempre logueado con `debugPrint` (nunca silenciado, seccion 9).
- Escrituras (`startFast`/`endFast`/`cancelFast`): sin conexion o error de Supabase se muestra como texto/snackbar curado en la pantalla, nunca un `catch` vacio. El caso especifico de unique-violation en `startFast` tiene su propio mensaje (ver arriba).

## Testing

- Unit test del repository: mapeo fila cruda -> `FastingSession` (mismo patron que `postgrest_numeric_test.dart` si `target_hours` u otra columna numerica necesita el helper `numFromPostgrest`; a confirmar el tipo exacto que devuelve PostgREST para una columna `integer` - probablemente ya es un `int` real, sin el problema de `numeric` como string que tienen `weight_kg`/etc., pero se verifica antes de asumir).
- Test de la traduccion del error de unique-violation (`23505`) a mensaje curado, con un fake/mock del error de Postgres.
- Test de la validacion client-side de `targetHours` personalizado (1-72).

## Fuera de alcance v1

- Rachas (`user_streaks`) - feature aparte, sin logica de calculo definida en ningun lado del producto todavia.
- Edicion de un ayuno ya terminado (cambiar `start_at`/`end_at`/`protocol` post-hoc) - no pedido, YAGNI.
- Notificaciones/recordatorios de fin de ayuno - fuera de alcance, no mencionado por Oscar.

## Verificacion manual esperada

- `flutter analyze` limpio (0 errores nuevos).
- `dart run build_runner build` limpio (freezed nuevo para `FastingSession`).
- `flutter test` con los tests nuevos en verde.
- En el dispositivo fisico Android: iniciar un ayuno, confirmar que el cronometro avanza, terminarlo, confirmar que aparece en el historial; iniciar uno y cancelarlo, confirmar que no queda ni activo ni en el historial; intentar iniciar un segundo ayuno mientras uno esta activo y confirmar el mensaje curado en vez de un error crudo.
