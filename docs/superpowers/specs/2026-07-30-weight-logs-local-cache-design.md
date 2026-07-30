# Weight logs + local read cache - diseño

Fecha: 2026-07-30
Estado: aprobado por Oscar, pendiente de plan de implementacion

## Contexto

Fase 3 (CLAUDE.md seccion 8) tiene pendientes: fasting timer, weight logs, favorites/recipes, offline-first. Esta sesion cubre dos de esos pendientes juntos:

1. **Weight logs**: la primera de las features vacias de Fase 3 que se implementa.
2. **Cache local de lectura**: el primer paso de "offline-first progresivo" (CLAUDE.md seccion 1, prioridad 7), acotado a lectura (sin cola de escritura offline en este corte).

Decisiones de alcance ya confirmadas con Oscar (ver conversacion):
- El cache cubre solo lectura, no escritura offline.
- La feature nueva de esta sesion es weight logs (no fasting timer ni favorites).
- Weight logs v1 es solo kg, sin toggle kg/lb.

## 1. Weight logs

### Esquema real (fuente de verdad: repo `nutriflow`)

Tabla `public.weight_logs` (`nutriflow/supabase/migrations/20260613_0007_body_and_fasting.sql:39-54`):

```
id              uuid primary key          -- sin default, se genera client-side
user_id         uuid not null             -- FK a public.users(id)
weight_kg       numeric(5,2) not null     -- check > 0 and < 500
body_fat_pct    numeric(4,2)              -- opcional, check 0-100
waist_cm        numeric(5,2)              -- opcional, check > 0
neck_cm         numeric(5,2)              -- opcional, check > 0
hips_cm         numeric(5,2)              -- opcional, check > 0
logged_at       timestamptz not null
created_at      timestamptz not null default now()
deleted_at      timestamptz               -- soft delete, no se usa en v1 (sin edicion/borrado)
```

Sin constraint de unicidad por dia: se permiten multiples logs por dia. RLS (`nutriflow/supabase/migrations/20260613_0011_clerk_rls.sql:44-49`) exige `user_id = app_user_id()` en select/insert/update/delete, `to authenticated`. No hay endpoint REST para esto (no hay logica de servidor involucrada, es CRUD simple segun CLAUDE.md seccion 6), asi que se implementa como lectura/escritura directa a Supabase, igual patron que `meal_logs_repository.dart`.

Todas las columnas `numeric` llegan de PostgREST como **strings JSON**, no numeros (mismo caso ya resuelto en `meal_logs_repository.dart` con el helper `_asNum`).

### Resolucion de `user_id` en el insert

`weight_logs.user_id` no tiene default en la tabla, asi que el insert debe incluirlo explicitamente para pasar el `with check` de RLS. Se resuelve llamando `supabase.rpc('app_user_id')` (la misma funcion SQL `security definer` que ya usa el RLS internamente, `grant execute ... to authenticated` en `20260613_0011_clerk_rls.sql:27-28`) en vez de reimplementar la resolucion clerk_id -> uuid interno en Dart. El resultado se cachea en memoria (provider) durante la sesion, no hace falta resolverlo en cada insert.

### `id` generado client-side

La tabla no tiene default para `id`. Se agrega el paquete `uuid` (nuevo en `pubspec.yaml`) y se genera un uuid v4 antes del insert, igual que hace Drizzle en el lado servidor para otras tablas insertadas desde la app web.

### Alcance de UI v1

- `models/weight_log.dart` (freezed): mirror de las columnas de arriba.
- `core/supabase/weight_logs_repository.dart`:
  - `fetchRecent({int limit = 30})`: lee `weight_logs` donde `deleted_at is null`, ordenado por `logged_at desc`, limitado.
  - `logWeight({required double weightKg, double? bodyFatPct, double? waistCm, double? neckCm, double? hipsCm, DateTime? loggedAt})`: resuelve `user_id` via RPC, genera `id`, inserta.
- `features/body_metrics/weight_log_screen.dart`:
  - Numero grande con el ultimo peso registrado + delta contra el registro anterior (mismo lenguaje visual que el hero card del dashboard, `shared/widgets/hero_card.dart`).
  - Formulario de registro: campo de peso obligatorio: seccion "avanzado" colapsada con body fat / waist / neck / hips (todos opcionales).
  - Lista de historial reciente (fecha + peso).
  - Sin edicion ni borrado en v1 (YAGNI - se agrega si se necesita despues).
- Sin toggle kg/lb en v1: todo se ingresa y se muestra en kg. La constante de conversion (`LB_PER_KG` en `nutriflow/src/app/onboarding/onboarding-client.tsx:46-53`) no se porta a Dart todavia porque no hay feature de peso que la use en ningun lado del producto (tampoco existe en la web); se agrega si Oscar lo pide mas adelante, junto con traer `measurementUnits` del perfil.
- Entrypoint: acceso nuevo desde el dashboard o `FloatingNavBar` (icono Lucide, a definir el lugar exacto durante la implementacion, sin agregar ruta si no hace falta - decision de detalle, no bloquea el diseno).

## 2. Cache local de lectura (Drift)

### Dependencias nuevas

`drift`, `drift_dev`, `sqlite3_flutter_libs`, `path_provider`, `path` (mas `uuid` para weight logs, ver arriba).

### Diseno: una tabla generica clave-valor, no una tabla Drift por entidad

```
CacheEntries:
  key        TEXT PRIMARY KEY   -- ej. 'today_meals', 'goal', 'weight_logs_recent'
  payload    TEXT               -- JSON crudo (la respuesta tal cual, antes de mapear a modelo)
  fetchedAt  DateTime
```

Se eligio esto sobre mapear cada entidad (`DayMealEntry`, `MacroGoal`, `WeightLog`) a su propia tabla Drift con columnas propias porque:
- Nunca se necesita filtrar/ordenar por columna dentro de los datos cacheados - siempre se lee "todo lo de hoy" o "el goal actual" completo, entero.
- Evita una migracion Drift nueva cada vez que se cachea una entidad mas (fasting, favorites, etc. en el futuro).
- Reutiliza el mapeo fila-cruda -> modelo que cada repositorio ya tiene para el camino en vivo (no hay una segunda copia de esa logica para el camino "leido del cache").

`core/local_db/app_database.dart`: clase Drift con la tabla `CacheEntries` y dos metodos, `putCache(String key, Object jsonEncodable)` / `Future<dynamic> getCache(String key)` (decodifica el JSON guardado, quien llama es responsable de interpretarlo, igual que ya interpreta la respuesta cruda de Supabase/HTTP).

### Patron de integracion por repositorio

```dart
Future<List<DayMealEntry>> fetchTodayEntries() async {
  try {
    final rows = await supabase.from('meal_items').select(...);
    await _cache.putCache('today_meals', rows);
    return rows.map(_toEntry).toList();
  } catch (e, st) {
    debugPrint('fetchTodayEntries failed, falling back to cache: $e\n$st');
    final cached = await _cache.getCache('today_meals');
    if (cached != null) {
      return (cached as List).cast<Map<String, dynamic>>().map(_toEntry).toList();
    }
    rethrow;
  }
}
```

Mismo patron para `goalProvider` (cachea el JSON decodificado de `GET /api/goals`) y para `WeightLogsRepository.fetchRecent` (cachea las filas crudas de `weight_logs`).

### UX en fallback a cache

Cuando una pantalla termina mostrando datos de cache (no de red), se muestra un aviso no bloqueante ("mostrando datos guardados, sin conexion") en vez de una pantalla de error - el error real sigue logueandose (`debugPrint`, ya es el patron existente desde el fix de 2026-07-17 documentado en CLAUDE.md), nunca se silencia segun la regla de la seccion 9. Sin red y sin cache todavia (primer uso offline de la app): se mantiene el comportamiento de error actual.

### Fuera de alcance v1

- Sin cola de escritura offline (loguear comida o peso sigue requiriendo conexion).
- Sin expiracion/TTL del cache: se sobreescribe en cada fetch exitoso, se lee tal cual cuando falla la red. Suficiente para "ultimo estado conocido", no se disenan politicas de invalidacion todavia.
- Sin cache para meal plan / fasting / favorites (no existen esas features en mobile todavia).

## 3. Testing

Primer archivo de test del repo: `test/local_cache_test.dart` (roundtrip `putCache`/`getCache`, y verificacion de que un repositorio cae al cache cuando la llamada de red lanza). Es el primer test que existe en `nutriflowMobile/test/` (hoy vacio, CLAUDE.md seccion 0 lo marca como pendiente).

## Verificacion manual esperada

- `flutter analyze` limpio (0 errores nuevos).
- `dart run build_runner build` limpio (freezed + drift codegen).
- Insertar un peso desde el dispositivo fisico Android (unico entorno donde auth funciona hoy, ver bitacora 2026-07-17) y confirmar que aparece en el historial.
- Apagar el servidor de `nutriflow` (o cortar red) con datos ya cacheados y confirmar que dashboard + weight logs siguen mostrando el ultimo estado conocido con el aviso de "sin conexion", en vez de pantalla en blanco/error.
