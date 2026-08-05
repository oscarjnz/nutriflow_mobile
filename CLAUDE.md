# CLAUDE.md - NutriFlow Mobile (Flutter)

> Esta es mi memoria viva y activa para este proyecto. No es documentacion decorativa: es la carta que consulto ANTES de cada respuesta (para saber que ya existe, que decision ya se tomo, que sigue) y actualizo DESPUES de cada respuesta con impacto real (para que la siguiente sesion, mia o de otra instancia, no repita trabajo ni errores). Si algo sale mal una vez, se documenta aqui para que no vuelva a pasar. Esta obligacion es religiosa: en cada proyecto/carpeta donde trabaje debo mantener un archivo asi.

---

## 0. Estado actual (leer esto primero, siempre)

> **PRIMERA ACCION DE CADA SESION, ANTES DE TOCAR NADA: `git branch --show-current`. Tiene que decir `main`.**
> Las sesiones del 2026-08-02, 08-04 y 08-05 corrieron sobre `master`, la rama obsoleta anterior a la publicacion, sin notarlo, y reimplementaron desde cero un fix que `main` ya tenia. `master` y `main` **no tienen ancestro comun** (el historial se reescribio al publicar), asi que git no avisa de nada: `git status` sale limpio y todo compila. `master` no tiene el fasting timer, ni el calendario, ni el perfil, ni el fix de UTC, ni 40 de los 47 tests. **`main` es la unica rama viva; `master` no se toca ni se mergea nunca.** Ver la entrada de bitacora "2026-08-05 (cierre)".
>
> Esa verificacion **ya no depende de que yo me acuerde**: hay un hook `SessionStart` en `.claude/settings.json` que corre `git branch --show-current` al abrir cada sesion y, si la rama no es `main`, inyecta una alerta en mi contexto y muestra un aviso en pantalla. Si alguna vez ese hook desaparece o se rompe, esta linea vuelve a ser la unica defensa. No borrarlo.

### Que es la app hoy (inventario, verificado 2026-08-05 sobre `main`)

Version `0.1.0+1`. Lo que abre y funciona, ruta por ruta (`lib/app/router.dart`):

| Ruta | Pantalla | Que hace |
|------|----------|----------|
| `/` | `_AuthGate` -> `_OnboardingGate` -> `DashboardScreen` | Login con Clerk; si el perfil no esta onboardeado, wizard de 5 pasos; si si, dashboard con meta de calorias, macros del dia y comidas registradas, con dia seleccionable y banner de "sin conexion" cuando los datos vienen del cache local |
| `/log` | `LoggingScreen` | Registro por descripcion libre en espanol (parseo NLP server-side) con eleccion de candidato de catalogo y gramos a mano |
| `/log/barcode` | `BarcodeScanScreen` | Captura por codigo de barras con la camara |
| `/weight` | `WeightLogScreen` | Registro de peso (y composicion corporal opcional) mas historial reciente con delta |
| `/calendar` | `CalendarScreen` | Vista de calendario del historial |
| `/profile` | `ProfileScreen` | Perfil del usuario |
| `/fasting` | `FastingScreen` | Timer de ayuno: iniciar, terminar, cancelar, con protocolos e historial |

Detras: Clerk en **produccion** con dominio propio (`nutriflow.dpdns.org`), Supabase con RLS por usuario, cache local de lectura en SQLite/Drift, y los endpoints REST de `nutriflow` (puerto **3002** en esta maquina). `flutter analyze` 0 errores, `flutter test` 47/47.

**Carpeta:** ya vive en `C:\Users\oscar\nutriflowMobile` como carpeta hermana independiente de `nutriflow` (repo web). Desde 2026-07-16 tiene `.git` propio (repo inicializado, commit inicial hecho con todo lo existente hasta esa fecha).

**Fase activa:** Fase 2 (setup del proyecto Flutter) sigue en marcha, mas avanzada de lo que la entrada de 2026-07-14 reflejaba. Fase 1 (endpoints REST) sigue HECHA.

**Ultimo hito verificado (2026-07-17):**
- `DashboardScreen` ya esta conectado a datos reales para "hoy": `core/supabase/meal_logs_repository.dart` hace un join directo `meal_items -> meal_logs -> foods` contra Supabase (RLS/`app_user_id()` filtra por usuario, no hay filtro `user_id` explicito en el cliente), y `core/supabase/providers.dart` expone `todayMealEntriesProvider` (FutureProvider) + `todayMacroTotalsProvider` (derivado, suma client-side porque no existe view/RPC de totales diarios). El goal sigue viniendo de `GET /api/goals` (`core/api/providers.dart: goalProvider`). El selector de dias de la semana (`HorizontalDaySelector`) SIGUE estatico - no hay query por dia de la semana todavia, solo "hoy".
- **RESUELTO (era HALLAZGO el mismo dia): el pipeline de codegen (`build_runner`) nunca habia funcionado en este proyecto**, ni siquiera para `MacroGoal` (que ya existia antes de hoy). Causa raiz doble: (1) `macro_goal.dart` estaba escrito con sintaxis de freezed 3.x (`abstract class X with _$X`) pero `pubspec.yaml` fijaba `freezed: ^2.5.7` (sintaxis vieja); (2) el `analyzer` que traia `build_runner 2.5.4` (tope transitivo, no subia solo con `pub upgrade`) no podia parsear sintaxis "dot-shorthand" que ya usan los sources de Flutter 3.44/Dart 3.12 (`Exception: Missing implementation of visitDotShorthandInvocation`). Forzar `analyzer` suelto via `dependency_overrides` rompia `dart_style` en cadena. **Se resolvio con el bump mayor coordinado** (`flutter pub upgrade --major-versions`): `flutter_riverpod`/`riverpod` 2.6.1->3.3.2, `riverpod_annotation` 2.6.1->4.0.3, `riverpod_generator` 2.6.5->4.0.4, `go_router` 14.8.1->17.3.0, `google_fonts` 6.3.3->8.2.0, que arrastro `analyzer` a 12.1.0 (soporta la sintaxis nueva) y `freezed` quedo en `3.2.6-dev.1` (no hay estable 3.2.x mas nuevo publicado; `4.0.0-dev.3` es prerelease, no vale la pena perseguirlo). `build_runner build` corre limpio (0 errores) y `flutter analyze` tambien (mismos 2 warnings preexistentes de siempre, ningun error nuevo por el bump - el uso de Riverpod/go_router en el codigo era basico: `Provider`, `FutureProvider`, `ConsumerStatefulWidget`, sin tocar API de go_router todavia). `MacroGoal`, `DayMealEntry`, `DayMacroTotals` volvieron a `@freezed` con sus `.freezed.dart`/`.g.dart` generados y commiteados.
- `core/api` (api_client, nutriflow_api, providers) y `core/supabase/supabase_bootstrap.dart` siguen igual salvo lo de abajo. Auth gate (`_AuthGate`, ahora en `app/router.dart`) sigue como se documento el 2026-07-16.
- **`go_router` YA ESTA WIREADO** (2026-07-17): `app/router.dart` define `appRouter` con rutas `/` (`_AuthGate`) y `/log` (`LoggingScreen`); `app.dart` usa `MaterialApp.router`. El auth gating sigue siendo un widget-swap en `/` (no `GoRouter.redirect`) - decision deliberada, no reabrir sin razon (ver comentario en `router.dart`).
- **Pantalla de logging manual por nombre YA EXISTE** (`features/logging/logging_screen.dart`): el usuario escribe una descripcion libre, se llama a `POST /api/nlp/parse` (ahora tipado: `models/parse_food_result.dart`, `parsed_item.dart`, `food_candidate.dart`, `extracted_food.dart`, todos `@freezed`), el usuario elige un candidato de catalogo por item detectado y confirma gramos a mano (NO se convierte cantidad+unidad a gramos en Dart - esa logica es `nutriflow/src/lib/nutrition/units.ts`, server-side, CLAUDE.md §2), y cada item confirmado se manda a un endpoint REST NUEVO: `POST /api/logging/log-meal` (creado hoy en el repo `nutriflow`, ver abajo). El FAB del `FloatingNavBar` en el dashboard ahora navega a `/log` y al volver invalida `todayMealEntriesProvider` para refrescar.
- **Endpoint nuevo en el repo `nutriflow` (2026-07-17, NO COMMITEADO todavia - Oscar debe revisar/commitear esa carpeta por separado):** `src/app/api/logging/log-meal/route.ts` envuelve `logMealAction` (ya existia, usado por la UI web) verbatim - mismo patron que `goals`/`meal-plan/log-planned`. Se extendio `quickLogSchema` (`src/lib/validation/meal.ts`) con un campo opcional `source` (default `'manual'` si se omite, backward-compatible con la web) para que mobile pueda mandar `source: 'nlp'`. `npm run typecheck` y `eslint` sobre los 3 archivos tocados corrieron limpios. **Ese repo tiene ademas otros archivos sin commitear de sesiones previas** (`.env.example`, `CLAUDE.md`, `src/env.server.ts`, `src/repositories/health.repo.ts`, `vercel.json`, `.agents/`, `.claude/`, `design/`, `skills-lock.json`) - no se tocaron ni se commitearon, quedan para que Oscar los revise en su propia sesion de `nutriflow`.
- **Bug real encontrado y corregido (2026-07-17): el cliente Dio (`core/api/api_client.dart`) no tenia timeout configurado.** Si el server de `nutriflow` esta apagado o una conexion se cuelga (paquetes perdidos, red rara) en vez de fallar rapido, la app se queda "buscando respuesta" indefinidamente sin mostrar error - asi se manifesto la primera vez que se probo el flujo de logging. Se agrego `connectTimeout: 10s` / `receiveTimeout: 30s` (30s porque `nlp/parse` llama a un LLM), y `_toFailure` ahora da mensajes en espanol para timeout/conexion en vez de solo repetir el mensaje crudo de Dio.
- **Bug real encontrado y corregido (2026-07-17): `meal_logs_repository.dart` casteaba columnas `numeric(8,2)` de Postgres (`quantity_grams`, `calories_snapshot`, `protein_snapshot`, `carbs_snapshot`, `fat_snapshot`) directo `as num`.** PostgREST serializa columnas `numeric` como **strings JSON**, no numeros, para no perder precision - el cast habria explotado (`String is not a subtype of num`) en cuanto hubiera una fila real en `meal_items`. No se habia notado porque no habia datos de prueba todavia. Se agrego un helper `_asNum` que acepta `String` o `num`. **Aprendizaje para no repetir:** cualquier columna `numeric`/`decimal` de Postgres leida via Supabase directo (no via los endpoints REST de `nutriflow`, que pasan por Drizzle + `JSON.stringify` y siempre dan numeros JSON reales) necesita este mismo manejo defensivo - revisar el tipo de columna en la migracion SQL antes de asumir `as num`/`as int` directo.
- Las demas carpetas de `features/` (`meal_plan`, `onboarding`, `fasting`, `body_metrics`, `favorites`) siguen VACIAS. Sigue sin tests (`test/` vacio o inexistente). Verificado con `flutter build web --debug` completo (compila limpio) - no hay dispositivo Android/iOS conectado en esta maquina para probar en vivo, solo Windows desktop (sin scaffold `windows/` todavia) y navegador.

**Aprendizaje para no repetir (build_runner vs analyzer):** si `dart run build_runner build` crashea con una excepcion de `analyzer` (`visitDotShorthandInvocation` o similar "Missing implementation of visitX"), NO asumir que es un bug en el codigo nuevo - primero correr `flutter analyze` solo para descartar errores reales de codigo. Si `flutter analyze` sale limpio pero `build_runner` crashea, es un desfase de version entre el `analyzer` que usa el SDK de Flutter (siempre al dia) y el `analyzer` transitivo de `build_runner` (se queda atras). La solucion que funciono fue `flutter pub upgrade --major-versions` (bump coordinado de todo el arbol de codegen/estado/router a la vez), no `dependency_overrides` puntuales sobre `analyzer` solo (eso rompe `dart_style`).

**Para probar el flujo de logging:** el server de `nutriflow` en esta maquina corre en **el puerto 3002, NO 3000** (`npm run dev -- -p 3002`; el 3000 esta ocupado por un proyecto sin relacion, `marvel`). `API_BASE_URL` en `env.json` (gitignored, por eso `env.example.json` no trae un puerto fijo) tiene que apuntar exactamente al puerto donde esa instancia especifica de `nutriflow` este corriendo - verificar con `netstat`/`Get-CimInstance Win32_Process` cual proceso `next dev` es cual antes de asumir 3000. Ademas `POST /api/nlp/parse` depende de que el LLM (Groq) este configurado en `nutriflow` (`GROQ_API_KEY`) - si falta, el endpoint responde 503 `llm_unavailable`.

**Verificado 2026-07-17 (noche) en dispositivo Android fisico (Samsung Galaxy A55, `flutter run -d <serial>`):** login con Google via Clerk funciona correctamente en un dispositivo real (a diferencia de emulador con red rota o desktop sin webview, ver bitacora). Con `API_BASE_URL` apuntando a la IP LAN de la maquina de desarrollo + puerto 3002 correcto, el dashboard carga bien (goal + totales + lista de comidas). Oscar confirmo que "todo esta correcto" para pasar a la siguiente fase.

**Ultimo hito verificado (2026-07-30):** weight logs (CRUD directo contra `weight_logs`) y un cache local de lectura generico (Drift/SQLite, `cachedFetch`) quedaron implementados y verificados estaticamente (`flutter analyze` 0 errores, `flutter test` 7/7, `flutter build apk --debug` limpio) - ver detalle completo en la seccion 8 y la entrada de bitacora del mismo dia. El cache ya cubre `todayMealEntriesProvider`, `goalProvider` y el nuevo `recentWeightLogsProvider`. Falta el QA manual en dispositivo fisico (sin Android conectado en esta sesion).

**Ultimo hito verificado (2026-07-31):** login arreglado en Windows (Google funciona de punta a punta con el flujo RFC 8252; errores de Clerk ya visibles), dashboard con fechas reales y dia seleccionable, y pantallas de calendario y perfil nuevas. Ver la entrada de bitacora del 2026-07-31 para el detalle de las tres causas raiz. Todo eso ya quedo commiteado en la rama `worktree-fasting-timer` (commits `4abfa9d`, `22dd7f3`, `684359d`, `07ff91f`, `50839a9`, `83b859e`); esa rama todavia no esta mergeada a `master`.

**Ultimo hito verificado (2026-07-31, cierre del dia):** **fasting timer implementado completo** (Fase 3), las 7 tareas del plan `docs/superpowers/plans/2026-07-31-fasting-timer.md` ejecutadas via `superpowers:subagent-driven-development` en la rama `worktree-fasting-timer`. La revision de tareas encontro tres defectos reales que el propio texto del plan habia mandado (el id de protocolo `custom` se filtraba a la UI en espanol en vez de la etiqueta; "Terminar" y "Cancelar" no eran mutuamente excluyentes, lo que podia dejar `end_at` y `deleted_at` en la misma fila y hacer desaparecer un ayuno terminado del historial; faltaban guardas `mounted` tras varios `await`) - la correccion goberno sobre el texto del plan. Rachas (`user_streaks`) se dejaron fuera de alcance a proposito para v1. Ver el detalle completo (incluyendo un `try`/`catch` que silenciaba errores y se quito en una ronda posterior, y un gotcha real de `cachedFetch` con tipos `T` nulleables) en la entrada de bitacora del 2026-08-01. Verificacion final (Tarea 7, corrida el 2026-08-01): `flutter analyze` 0 errores (7 infos preexistentes, ninguno nuevo), `flutter test` 33/33, `build_runner` regenero contenido identico (solo diffs de fin de linea CRLF/LF por el checkout de Windows, descartados), `flutter build apk --debug` limpio. **Estado posterior: la revision final del branch se hizo el 2026-08-01 (dos revisores, ver la entrada de ese dia) y la rama se publico como `main`. NO hay merge pendiente a `master` - `master` es la rama obsoleta, ver el aviso al inicio de esta seccion. Lo unico que sigue pendiente de aqui es el QA manual del ayuno en el Galaxy A55.**

**Ultimo hito verificado (2026-08-05):** **Clerk esta en PRODUCCION con dominio propio (`nutriflow.dpdns.org`) y el login funciona end-to-end en Windows**, con la app completa detras (onboarding con cuenta nueva + dashboard, todos los endpoints devolviendo 200). Ojo con dos cosas al retomar: eso se verifico sobre `master`, o sea sobre el fix de deep link viejo, **no sobre el loopback RFC 8252 que usa `main`** (ver el aviso de la entrada del 2026-08-02 sobre la whitelist de redirect URLs de la instancia de produccion); y **en el Galaxy A55 el login de produccion no se ha vuelto a probar** desde la migracion. Detalle completo en las entradas de bitacora del 2026-08-02 y 2026-08-05.

**Siguiente accion concreta (decidir con Oscar):** (0) **verificar que el login de Windows sigue funcionando ahora que el checkout esta en `main`** - es lo unico que cambio de mecanismo (loopback en vez de `com.clerk.flutter://`) y es lo que puede romperse contra la instancia de produccion de Clerk; (a) **QA manual del feature de weight logs + cache offline en el Galaxy A55** (guardar peso, ver historial, apagar red y confirmar que el dashboard y la pantalla de peso siguen mostrando datos con el banner de "sin conexion"), primera vez que haya un dispositivo fisico disponible; (b) revisar y commitear en `nutriflow` los endpoints REST que ahi siguen sin commitear (`goals`, `logging/log-meal`, `foods/barcode-lookup`, `foods/selectable`, `onboarding/status`) + los demas archivos pendientes de sesiones previas; (c) **probar el wizard de onboarding de punta a punta con una cuenta nueva** (todavia no se hizo, solo se verifico que no rompe cuentas ya onboardeadas); (d) seguir con el resto de Fase 3 (edicion de foods, favorites/recipes) - weight logs, el cache local y el fasting timer ya estan hechos.

**Ultimo hito verificado (2026-08-01):** revision final del branch hecha (dos revisores en paralelo), **con un hallazgo critico real: todas las marcas de tiempo se escribian como hora local sin offset en columnas `timestamptz`**, lo que hacia que un ayuno recien iniciado marcara "4h 0m" y que las comidas de la noche cayeran en el dia equivocado. Corregido con el helper `pgTimestamp` + `.toLocal()` en las lecturas; ver la entrada de bitacora del 2026-08-01 (cierre). `flutter analyze` 0 errores, `flutter test` 43/43.

**PUBLICADO el 2026-08-01: https://github.com/oscarjnz/nutriflow_mobile** (publico, licencia **MIT** a nombre de Oscar, rama `main`, tag `v0.1.0`, version `0.1.0+1`). **La rama de trabajo de este worktree se llama ahora `main` y sigue a `origin/main`; la rama local `master` quedo obsoleta tras la reescritura de historial y NO se debe mergear sobre `main`** (son historias sin relacion). El `README.md` ya no es el boilerplate de `flutter create`. **Falta antes de publicar un APK de verdad:** desplegar el backend en HTTPS, quitar el `network_security_config.xml` de cleartext, y firmar con una keystore propia (los dos ultimos ya anotados en el TODO de `android/app/build.gradle.kts`). La guia completa del proceso (llaves, versionado, keystore, APK, Play, Clerk a produccion) esta en `C:\Users\oscar\OneDrive\Escritorio\NutriFlow - Guia de publicacion.txt`.

**APK release instalado y verificado en el Galaxy A55 (2026-08-01):** compilado desde esta rama con todos los arreglos de la revision, instalado con `adb install -r`, arranca sin `FATAL` ni excepciones en logcat y el telefono alcanza el backend (`nc` a `192.168.100.130:3002` da exit 0).

**QA manual pendiente en el Galaxy A55** (iniciar/terminar/cancelar un ayuno, confirmar que el segundo ayuno se bloquea con "Ya tienes un ayuno en curso.", y el banner de "sin conexion" con la red apagada), que cubre a la vez el QA pendiente de weight logs. **Al iniciar un ayuno, mirar el numero en los primeros diez segundos**: debe decir "0h 0m", no "4h 0m". Ese es el chequeo que detecta la regresion de UTC si alguna vez vuelve.

---

## 1. Identidad y rol

Actuo como el mismo cofundador tecnico de largo plazo que en el repo web `nutriflow` (ver `../CLAUDE.md` alli, seccion 1), aplicado ahora a la capa mobile: Principal Mobile Architect + Senior Flutter/Dart Engineer + UX Architect. No genero prototipos de juguete ni pantallas placeholder. Toda entrega es production-ready o no se entrega.

Prioridades, en este orden (heredadas del proyecto padre, adaptadas):

1. Nunca duplicar logica de negocio que ya vive en el backend web (calculos nutricionales, generacion de plan, NLP). Este cliente CONSUME esa logica, no la reimplementa en Dart.
2. Seguridad y privacidad del usuario (RLS de Supabase respetada siempre, tokens de Clerk manejados correctamente, nunca persistir secretos en el cliente).
3. Type safety estricto (Dart null-safety, sin `dynamic` salvo deserializacion justificada).
4. Performance percibido (mismo mandato <5s por comida registrada que en la web).
5. Mantenibilidad y arquitectura limpia.
6. Paridad visual con el sistema de diseno web (Soft Structuralism, ver seccion 5).
7. Offline-first progresivo (fase avanzada, no bloquea el MVP).

---

## 2. Producto y relacion con el repo web

NutriFlow Mobile es el cliente Flutter (iOS/Android) del mismo producto que ya existe como PWA Next.js en `C:\Users\oscar\nutriflow` (o `../nutriflow` una vez movida esta carpeta fuera). Mismo backend, mismo Supabase, mismo Clerk, misma base de usuarios. No es un producto aparte ni una reescritura: es un segundo cliente sobre la misma plataforma.

**Regla dura:** cualquier calculo cientifico (BMR, TDEE, macros, generacion de plan de comidas, agregaciones) NUNCA se reimplementa en Dart. Vive en `nutriflow/src/lib/nutrition/*` (TypeScript, puro, testeado) y se consume via los endpoints REST de la Fase 1. Si en algun momento parece mas rapido "solo calcularlo aqui en Dart", es una senal de alarma: pausar y usar el endpoint correspondiente, o pedir que se cree si no existe.

Fuente de verdad del modelo de datos, RLS, y reglas de producto: `nutriflow/CLAUDE.md` (el archivo raiz del repo web). Este archivo no lo duplica, lo referencia.

---

## 3. Restriccion economica

Igual que el repo web: todo el stack en planes gratuitos, sin tarjeta de credito. Flutter mismo es gratis. `supabase_flutter` y el SDK de Clerk para Flutter son gratis. El unico costo real de todo este plan es la cuenta de Apple Developer (99 USD/anio) si se decide publicar en iOS - se evalua en la Fase 4, no antes, y no se compra sin decision explicita de Oscar.

---

## 4. Stack tecnologico

| Capa | Tecnologia | Motivo |
|------|------------|--------|
| Framework | Flutter (ultimo stable) | Un solo codebase para iOS + Android, gratis |
| Lenguaje | Dart, null-safety estricto | Coherente con el `strict` de TypeScript en el repo web |
| Estado | Riverpod | Equivalente conceptual a Zustand + TanStack Query del repo web (estado local + estado de servidor cacheado) |
| Networking | `supabase_flutter` (CRUD directo) + `http`/`dio` para los endpoints REST propios | Enfoque hibrido, ver seccion 6 |
| Auth | `@clerk/clerk_flutter` (SDK oficial de Clerk para Flutter) | Mismo proveedor que la web, sesion compartida por usuario |
| Modelos | `freezed` + `json_serializable` | Inmutabilidad y parseo seguro, equivalente a los tipos Zod-derivados de la web |
| Navegacion | `go_router` | Deep linking, estandar de facto en Flutter moderno |
| Offline (fase avanzada) | Drift (SQLite) o cache local de `supabase_flutter` | Espeja la estrategia offline-first que el CLAUDE.md web ya definia para la PWA |
| Escaneo de codigo de barras | `mobile_scanner` (agregado 2026-07-17, Fase 3.5) | CameraX en Android / AVFoundation en iOS, activamente mantenido |

Cualquier cambio a esta tabla se decide con Oscar antes de instalar la dependencia, igual que la regla del repo web para dependencias mayores.

---

## 5. Sistema de diseno (portado 1:1 del repo web, no reinterpretado)

Fuente: `nutriflow/src/app/globals.css`. Arquetipo "Soft Structuralism": superficies flotantes, sombras calidas difusas, tipografia grotesca limpia, motion contenido. Mobile-first ya en origen.

### Paleta (modo claro) - convertir estos HSL a Color de Flutter tal cual, sin reinterpretar tonos
```
background:        hsl(40 30% 99%)
foreground:         hsl(35 16% 15%)
card:                hsl(0 0% 100%)
card-foreground:    hsl(35 16% 15%)
primary (unico acento): hsl(95 30% 42%)
primary-foreground: hsl(40 30% 99%)
muted:               hsl(40 24% 95%)
muted-foreground:   hsl(35 10% 42%)
border / input:      hsl(40 18% 88%)
ring:                hsl(95 30% 42%)
destructive:         hsl(8 72% 52%)
destructive-foreground: hsl(40 30% 99%)

macro-protein: hsl(95 30% 42%)
macro-carbs:   hsl(36 90% 50%)
macro-fat:     hsl(18 74% 55%)
```

### Paleta (modo oscuro)
```
background:        hsl(40 12% 7%)
foreground:         hsl(40 20% 94%)
card:                hsl(40 10% 11%)
card-foreground:    hsl(40 20% 94%)
primary:             hsl(95 38% 52%)
primary-foreground: hsl(40 12% 7%)
muted:               hsl(40 8% 17%)
muted-foreground:   hsl(40 12% 62%)
border / input:      hsl(40 8% 18%)
ring:                hsl(95 38% 52%)
destructive:         hsl(8 62% 48%)
destructive-foreground: hsl(40 20% 94%)

macro-protein: hsl(95 38% 52%)
macro-carbs:   hsl(36 85% 55%)
macro-fat:     hsl(18 70% 58%)
```

### Otros tokens
- Radio base: `0.75rem` (12px). Tarjetas/dialogs mas generosos (equivalente a `rounded-[1.5rem]` = 24px en la web), tiles de lista `rounded-2xl` = 16px, inputs/botones `rounded-lg/xl` = 8-12px, chips/pills full round.
- Sombras: NUNCA usar `Colors.black` en `BoxShadow`. Portar el mismo principio "warm-tinted": el color de la sombra se mezcla del `foreground` (claro) o negro suave con alpha bajo (oscuro), con un highlight interior superior sutil si el widget lo permite (Flutter no tiene `inset` shadow nativo; usar un borde superior claro de 1px como aproximacion, o `decoration` con gradiente sutil).
- Tipografia: Plus Jakarta Sans via `google_fonts` o fuente empaquetada localmente (mejor: empaquetada, para no depender de red). Prohibido usar la fuente por defecto del sistema como marca.
- Numeros: siempre con `FontFeature.tabularFigures()`.
- Icons: `lucide_icons` (paquete Flutter que replica Lucide) para paridad exacta con `lucide-react` de la web. No mezclar con Material Icons salvo cuando Lucide no tenga el icono (documentar la excepcion aqui si pasa).
- Motion: curva estandar `Cubic(0.23, 1, 0.32, 1)` (la misma bezier que la web). Animar solo transform/opacity. Respetar la config de accesibilidad del sistema (`MediaQuery.disableAnimations`).
- Cero em dash (`—`) en cualquier texto de UI o comentario. Guion normal `-` unicamente.
- Texto de UI en espanol. Codigo, identificadores, comentarios en ingles.
- Contraste AA en todo control interactivo.
- **Emojis limitados en toda la app (decidido 2026-08-01, pedido explicito de Oscar):** el objetivo es que la app no se sienta "hecha con IA". Nada de emojis decorativos en copy de UI, textos vacios (empty states), mensajes de error, ni titulos. Aplica tambien a las notificaciones push (seccion 8, backlog de Notificaciones) sin excepcion. Iconos Lucide (ya definidos arriba) siguen siendo el vehiculo visual normal; un emoji puntual solo se justifica si aporta algo que un icono no puede (a confirmar caso por caso con Oscar, no por defecto).
- **La pantalla de login de Clerk sigue en INGLES** ("Sign in to NutriFlow", "Email address", "Continue"), lo cual viola la regla de UI en espanol de arriba. Es la unica pantalla de la app en ingles y es la primera que ve un usuario nuevo. Se arregla con el parametro `localizations` (`ClerkSdkLocalizationsCollection`) de `ClerkAuthConfig` en `lib/core/auth/clerk_bootstrap.dart`. Detectado el 2026-08-04, sin arreglar todavia.

---

## 6. Arquitectura: enfoque hibrido (decision tomada, no reabrir sin razon fuerte)

- **CRUD simple** (`meal_logs`, `weight_logs`, `favorites`, `fasting_sessions`, lectura de `foods`/`food_aliases`): Flutter llama a Supabase **directo** via `supabase_flutter`. Las RLS del repo web (`app_user_id()`, migracion `0011_clerk_rls.sql`) ya filtran por usuario usando el claim `sub` del JWT de Clerk. No se reescribe ninguna policy.
- **Logica de servidor** (generar/regenerar plan, parseo NLP con Groq, cualquier cosa hoy detras de Server Actions en la web): se llama via HTTP a los Route Handlers REST nuevos en `nutriflow/src/app/api/*` (Fase 1), pasando el JWT de Clerk como `Authorization: Bearer`.
- **Auth bridge:** el SDK de Clerk Flutter entrega el token de sesion (`session.getToken()` equivalente en Dart). Ese mismo token se usa (a) como `accessToken` callback al inicializar `Supabase.initialize(...)` para las llamadas directas, y (b) como header `Authorization` en las llamadas a los endpoints REST propios.

Por que este enfoque y no una API REST completa: evita duplicar toda la superficie CRUD que las RLS ya cubren, reduce el codigo nuevo a mantener, y el spike (seccion 10) ya probo que funciona de punta a punta.

---

## 7. Estructura de carpetas esperada (cuando arranque el codigo)

```
nutriflowMobile/
  lib/
    main.dart
    app/                    Router (go_router), tema, arranque
    core/
      auth/                 Wrapper del Clerk SDK, provider de sesion
      supabase/              Cliente Supabase inicializado con accessToken de Clerk
      api/                   Cliente HTTP tipado hacia nutriflow/src/app/api/*
      theme/                 Tokens portados de la seccion 5 (colors.dart, radii.dart, shadows.dart, typography.dart, motion.dart)
    features/                Igual filosofia feature-based que el repo web
      dashboard/
      logging/
      meal_plan/
      onboarding/
      fasting/
      body_metrics/
      favorites/
    shared/
      widgets/               Equivalente a components/ui + components/shared de la web
    models/                  Clases freezed que espejan los tipos de nutriflow/src/types
  test/
  assets/
    fonts/                   Plus Jakarta Sans empaquetada
    icons/
  pubspec.yaml
  CLAUDE.md                  este archivo
```

---

## 8. Roadmap por fases (fuente: plan aprobado 2026-07-10, `C:\Users\oscar\.claude\plans\crees-que-esto-se-concurrent-stearns.md` en la maquina de Oscar)

| Fase | Entregable | Estado | Donde se ejecuta |
|------|------------|--------|-------------------|
| 0 | Validar puente Clerk -> Supabase (RLS con JWT real) | **HECHO 2026-07-10** (ver bitacora) | repo `nutriflow` (dashboards Clerk + Supabase) |
| 1 | Endpoints REST en `nutriflow/src/app/api/`: `meal-plan/regenerate`, `meal-plan/log-planned`, `nlp/parse`, `onboarding/complete`, `onboarding/food-selections`, `goals` | **HECHO** (verificado 2026-07-14, los 6 archivos existen) | repo `nutriflow` |
| 2 | Setup del proyecto Flutter aqui: `supabase_flutter` + Clerk SDK, theme portado, pantallas MVP (login, dashboard, registro manual, ver plan) | **EN CURSO** - stack, theme, auth bridge, API client, auth gate, y `DashboardScreen` (datos reales de hoy) ya existen; falta registro manual de comidas y ver plan | este repo (`nutriflowMobile`) |
| 3 | Paridad ampliada: onboarding completo, edicion de foods, fasting timer, weight logs, favorites/recipes, offline-first | **Onboarding completo HECHO** (2026-07-17 noche); **weight logs + cache local de lectura HECHO** (2026-07-30); **fasting timer HECHO** (2026-07-31, revisado y publicado en `main`; solo falta el QA manual en dispositivo fisico); falta edicion de foods, favorites/recipes | este repo |
| 3.5 | **Captura de comida por codigo de barras + busqueda por nombre** (pedido por Oscar 2026-07-17) | **HECHO** (2026-07-17 noche), ver detalle abajo | ambos repos |
| 4 | Distribucion Android/iOS | Pendiente | este repo |

### Backlog (pedido por Oscar 2026-08-01, no priorizado todavia)

- **Notificaciones.** Varios tipos distintos, no una sola generica:
  1. Notificacion tipo "media en curso" durante el ayuno (persistente/actualizable, como el widget de reproduccion de Spotify), mostrando tiempo transcurrido en vivo mientras el timer de `fasting` esta activo.
  2. Recordatorios a hora fija para registrar comidas ("Recuerda registrar tu desayuno/almuerzo/cena", horarios probablemente configurables por el usuario, a definir).
  3. Aviso tardio en el dia si no se llego a la meta de calorias ("hoy no lo lograste"), una sola vez, no repetitivo.
  4. Mensaje de felicitacion cuando si se cumple la meta del dia.
  - Sin disenar todavia: mecanismo tecnico (local notifications vs push real via FCM/APNs, quien dispara el aviso de "meta no cumplida"/"felicidades" - necesita un job que corra a una hora fija, no algo que el cliente pueda calcular solo si la app esta cerrada), copy exacto de cada mensaje, y si son configurables/silenciables por el usuario. Sujeto a la regla de emojis limitados de la seccion 5.
- **Dominio propio para Clerk en produccion + Supabase sin auto-pausa.** Cadena tecnica completa montada y verificada: dominio real **`nutriflow.dpdns.org`** (via DigitalPlat FreeDomain; NO es `qzz.io`, que fue solo la recomendacion inicial), DNS en Cloudflare, Supabase Third-Party Auth apuntando al dominio nuevo, Vercel y `env.json` con llaves `_live_`. **Login de produccion verificado end-to-end en Windows el 2026-08-05**; en el Galaxy A55 sigue sin reprobarse desde la migracion. Cron de keep-alive de Supabase (`.github/workflows/supabase-keepalive.yml`) creado el 2026-08-01, sin commitear ni pushear todavia a la espera de que Oscar lo confirme (activarlo consume minutos de Actions del repo publico).

**Nota de coordinacion entre repos:** la Fase 1 se hace desde una sesion de Claude Code con working directory en `nutriflow` (no aqui), porque toca codigo TypeScript del backend. Cuando ambas carpetas sean hermanas (`nutriflow` y `nutriflowMobile`), cada sesion opera en su propio directorio; hay que traer el contexto manualmente de un lado a otro (memoria + este archivo) porque las sesiones no se ven entre si automaticamente.

### Detalle Fase 3 - weight logs + cache local de lectura (HECHO 2026-07-30)

Plan ejecutado tal cual: `docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md` (spec aprobada) + `docs/superpowers/plans/2026-07-30-weight-logs-local-cache.md` (10 tareas). Las tareas 1-9 quedaron commiteadas (ver `git log`: desde `chore: add drift/sqlite and uuid dependencies...` hasta `feat: wire the dashboard's body-metrics tab to the weight log screen`); esta entrada cierra la Tarea 10 (verificacion final), que se habia quedado sin correr ni commitear de la sesion anterior.

- **Cache local de lectura (generico, no solo para weight logs):** tabla Drift/SQLite `CacheEntries` (`lib/core/local_db/app_database.dart`, key-value: `key`, `payload` JSON, `fetchedAt`), envuelta por la interfaz `LocalCache` (`local_cache.dart`, separada de `DriftLocalCache` a proposito para poder testear contra un fake sin SQLite real, ver Tarea 3 del plan) y expuesta via `localCacheProvider`/`appDatabaseProvider` (`local_db/providers.dart`).
- **`cachedFetch` (`lib/core/local_db/cached_fetch.dart`):** helper unico "intenta red, cachea el JSON crudo en exito, decodifica-desde-cache en fallo, re-lanza si falla la red y no hay nada cacheado" - reusado por los 3 providers de lectura de la app en vez de triplicar esa logica. Con 4 tests unitarios contra un `_FakeLocalCache` (`test/cached_fetch_test.dart`).
- **Retrofit de los 2 providers de lectura que ya existian:** `todayMealEntriesProvider` (`core/supabase/providers.dart`) y `goalProvider` (`core/api/providers.dart`) ahora devuelven `CachedValue<T>` en vez del tipo pelado - cualquier consumidor futuro de esos dos providers debe desenvolver `.value`. El dashboard (`dashboard_screen.dart`) ya se actualizo para eso y ademas muestra un banner "Sin conexion: mostrando los ultimos datos guardados." cuando `goalCached.fromCache` es true.
- **`numFromPostgrest` (`lib/core/supabase/postgrest_numeric.dart`):** se extrajo el helper que ya existia inline en `MealLogsRepository` (`_asNum`, ver bitacora 2026-07-17) a un archivo compartido con 3 tests (`test/postgrest_numeric_test.dart`), porque `WeightLogsRepository` necesitaba exactamente el mismo manejo defensivo de columnas `numeric` de Postgres (`weight_kg`, `body_fat_pct`, etc. llegan como strings JSON via PostgREST).
- **Weight logs (feature nueva):** `WeightLog` (freezed, `lib/models/weight_log.dart`) mirror de `public.weight_logs`; `WeightLogsRepository` (`core/supabase/weight_logs_repository.dart`) hace CRUD directo contra Supabase igual que `meal_logs` (CLAUDE.md seccion 6) - lecturas (`fetchRecent`) pasan por el cache local, escritura (`logWeight`) resuelve `user_id` via el RPC `app_user_id()` (la misma funcion que usan las RLS internamente) e `id` client-side con `uuid` v4. v1 es kg-only, sin toggle kg/lb, sin editar/borrar (alcance definido en la spec). `WeightLogScreen` (`features/body_metrics/weight_log_screen.dart`) tiene el formulario (peso obligatorio + composicion corporal opcional colapsable: grasa%, cintura, cuello, cadera) y el historial reciente con card de "ultimo registro" (incluye delta vs el anterior).
- **Navegacion:** ruta `/weight` en `app/router.dart`; el tab `heartPulse` del `FloatingNavBar` del dashboard ahora empuja a esa ruta (antes solo cambiaba el indice visual sin navegar).
- **Verificacion final (Tarea 10, corrida en esta entrada):** `flutter analyze` completo, 0 errores (7 infos preexistentes de estilo, ninguno nuevo bloqueante); `flutter test`, 7/7 tests pasan (`postgrest_numeric_test.dart` + `cached_fetch_test.dart`); `dart run build_runner build` confirma el codegen ya estaba al dia (0 archivos escritos); `flutter build apk --debug` compila limpio (unico warning es el ya conocido de KGP en `mobile_scanner`/`passkeys_android`/`ua_client_hints`, no relacionado con este trabajo). **Sigue pendiente el QA manual en dispositivo fisico** (probar guardar un peso, ver el historial, y forzar el banner de "sin conexion" apagando la red) - esta maquina no tenia un Android fisico ni emulador conectado en esta sesion (`flutter devices` solo listaba Windows desktop/Chrome/Edge, ninguno sirve para probar Clerk+Supabase de punta a punta, ver bitacora 2026-07-17 noche). Queda para la proxima vez que Oscar conecte el Galaxy A55.

### Detalle Fase 3.5 - captura por codigo de barras / nombre (HECHO 2026-07-17 noche)

Busqueda por nombre ya estaba hecha (ver bitacora del mismo dia, mas temprano). Esta sesion completo el codigo de barras, siguiendo el orden sugerido que se dejo anotado:

- **Endpoint nuevo en `nutriflow`:** `src/app/api/foods/barcode-lookup/route.ts` (POST, body `{ barcode: string }`), envuelve `lookupBarcodeAction` verbatim - mismo patron que `goals`/`log-meal` (auth via `getUser()`, 401 si no hay sesion, 422 si `lookupBarcodeAction` devuelve `{ ok: false }`). Responde `{ food: FoodSearchResult }` en exito. `tsc --noEmit` y `eslint` sobre el archivo nuevo corrieron limpios. **NO COMMITEADO todavia en ese repo** (mismo estado que `log-meal` - Oscar revisa/commitea `nutriflow` en su propia sesion).
- **Mobile:** se agrego `mobile_scanner` a `pubspec.yaml` (decision ya aprobada por Oscar al pedir seguir con Fase 3.5), con permiso de camara en `AndroidManifest.xml` (`CAMERA` + features opcionales) e `Info.plist` (`NSCameraUsageDescription`) para iOS. Modelo nuevo `models/food_search_result.dart` (freezed) mirror de `FoodSearchResult` (`nutriflow/src/repositories/foods.repo.ts`). `NutriFlowApi.lookupBarcode(String barcode)` en `core/api/nutriflow_api.dart` llama al endpoint nuevo. Pantalla nueva `features/logging/barcode_scan_screen.dart`: camara en vivo (`MobileScanner`) -> detecta codigo -> llama `lookupBarcode` -> muestra el producto resuelto con control de gramos (igual patron que `LoggingScreen`) -> `logMeal(..., source: 'barcode')`. Ruta `/log/barcode` en `app/router.dart`, entrypoint como icono (`LucideIcons.scanLine`) en el AppBar de `LoggingScreen`.
- **Verificado en el emulador Android** (sin datos reales por la camara virtual en negro, pero sin crashear): navegacion `/log` -> icono de escanear -> `/log/barcode` renderiza limpio, sin excepciones en logcat. `flutter analyze` da 0 errores (solo los 3 infos preexistentes de siempre). `flutter build apk --debug` compila limpio con el plugin nativo nuevo. **Falta probar la deteccion real de un codigo de barras en un dispositivo fisico** (la camara del emulador no tiene feed real) - Oscar puede hacerlo la proxima vez que conecte el telefono.
- Tambien se elimino `test/widget_test.dart` (boilerplate del contador default que `flutter create --platforms=windows .` genero en la sesion anterior, no aplicaba a esta app y rompia `flutter analyze`).

### Detalle Fase 3 - onboarding completo (HECHO 2026-07-17 noche, mismo dia que Fase 3.5)

Seguido de Fase 3.5, se implemento el wizard de onboarding completo (~15 campos + paso de seleccion de alimentos con minimos por categoria). Investigado en la web (`onboarding-client.tsx`, `onboarding.ts` schema, `features/onboarding/actions.ts`, `options.ts`, `food-selection.ts`) antes de tocar Dart, siguiendo la regla de nunca reimplementar logica de servidor - el wizard mobile solo recolecta las mismas respuestas y las manda tal cual a `POST /api/onboarding/complete`, que ya hacia todo el calculo (`computeBodyPlan`, generacion de plan, minimos de categoria) desde Fase 1.

- **2 endpoints nuevos en `nutriflow`** (mismo patron que los anteriores, `getUser()` + 401/422):
  - `GET /api/onboarding/status` -> `{ completed: boolean }`, envuelve el helper ya existente `hasCompletedOnboarding` (`user-profile.repo.ts`). Mirror exacto del check `profile?.onboardingCompleted` que hace `onboarding/page.tsx` en la web para decidir si redirigir.
  - `GET /api/foods/selectable` -> `{ foods: SelectableFood[] }` (id, nameEs, category), envuelve `listSelectableFoods()`. Los minimos por categoria (`CATEGORY_META` en `food-selection.ts`) NO se sirven desde el backend - son datos estaticos, se duplicaron tal cual en Dart (`features/onboarding/food_category.dart`), y el servidor sigue siendo quien re-valida de forma autoritativa en `completeOnboardingAction`.
  - `tsc --noEmit`/`eslint` limpios en ambos. **NO COMMITEADOS todavia** (mismo estado que el resto de `src/app/api/*` en ese repo).
- **Mobile:**
  - `features/onboarding/onboarding_options.dart`: opciones (goal/method/sex/activity/diet/pace/suggestionStyle/fasting/measurementUnits), copiadas tal cual de `options.ts`.
  - `features/onboarding/food_category.dart`: `CATEGORY_META` + `selectionMeetsMinimums()`, puerto directo de `food-selection.ts` (misma logica de gating client-side, servidor re-valida).
  - `models/selectable_food.dart` (freezed), mirror de `SelectableFood`.
  - `NutriFlowApi.getOnboardingStatus()` y `.getSelectableFoods()` nuevos; `completeOnboarding()` ya existia (Fase 1) y no cambio.
  - `onboardingStatusProvider` (FutureProvider.autoDispose) en `core/api/providers.dart`.
  - **Pantalla nueva `features/onboarding/onboarding_screen.dart`**: wizard de 5 pasos (perfil, meta, actividad/dieta, plan de comidas, alimentos disponibles) con barra de progreso, validacion de "Continuar" por paso (recordName no vacio, minimos de categoria en el ultimo paso), y submit final a `completeOnboarding`. Reutiliza el patron `_OptionCard`/`_NumberField` propio, iconos Lucide (no Material) por la regla de seccion 5.
  - **`app/router.dart` reestructurado:** `_AuthGate` (signed-in) ahora entra a un `_OnboardingGate` nuevo (`ConsumerWidget`) que lee `onboardingStatusProvider` y muestra `OnboardingScreen` o `DashboardScreen` segun `completed`. Sigue siendo un widget-swap, no `GoRouter.redirect` (misma decision de siempre, ver comentario en el archivo). `OnboardingScreen` no tiene ruta propia - se llega solo via el gate, igual que `DashboardScreen`.
- **Verificado en el emulador Android:** la cuenta ya onboardeada (Oscar, la misma de toda la sesion) paso derecho al dashboard sin bloquearse - confirma que `onboardingStatusProvider` + el endpoint nuevo funcionan end-to-end para el caso "ya completo". `flutter analyze` 0 errores, `flutter build apk --debug` compila limpio. **Falta probar el wizard completo en si** (una cuenta nueva, sin onboarding) - no se forzo por tiempo/alcance de la sesion; la cuenta de prueba creada durante el debugging de Windows quedo en un estado incierto (el sign-up parecio colgarse por el bug de Clerk+webview documentado esa noche) y no se uso para este test.
- Iconos: se reemplazaron 4 usos de `Icons.*` (Material) por sus equivalentes Lucide (`arrowLeft`, `circleCheck`, `circleMinus`, `circlePlus`) para cumplir la regla de seccion 5 de no mezclar sistemas de iconos.

---

## 9. Reglas de codigo (una vez arranque Dart)

- Null-safety estricto, prohibido `dynamic` salvo en el borde de deserializacion JSON (y ahi, inmediatamente parseado a un modelo `freezed` tipado).
- Prohibido logica de negocio/calculo numerico en widgets. Los widgets solo muestran datos que ya vienen calculados del backend.
- Prohibido llamar a Supabase o a los endpoints REST directo desde un widget: pasa por un repository/service en `core/api` o `core/supabase`, igual que el patron repository del repo web.
- Cada feature expone solo lo necesario (equivalente al "prohibido export *" de la web).
- Componentes accesibles por defecto: `Semantics` labels, foco visible, contraste AA.
- Convencion de commits: Conventional Commits (igual que el repo web).
- Nunca silenciar errores. Nunca `catch` vacio. Todo error se loggea con contexto o se propaga.

---

## 10. Bitacora viva

> La mantengo yo (Claude), no Oscar. Entrada nueva (mas reciente arriba) cada vez que hay un cambio de alcance, una decision no trivial, un error de raiz, o una confirmacion de un enfoque no estandar. Esta seccion es la que leo primero para no repetir trabajo ni errores ya resueltos.

### 2026-08-05 (cierre) - Tres sesiones trabajaron sobre la rama obsoleta `master` sin darse cuenta

Este es el hallazgo mas importante del dia y explica retroactivamente casi todo lo raro de las tres sesiones anteriores. **Las sesiones del 2026-08-02, 08-04 y 08-05 tuvieron el checkout principal (`C:\Users\oscar\nutriflowMobile`) parado en `master`, la rama obsoleta anterior a la publicacion, no en `main`.** Ninguna lo noto.

Como quedo asi: al publicar el 2026-08-01 se reescribio el historial con `git filter-repo` y la rama de trabajo (`worktree-fasting-timer`) se renombro a `main`, que quedo viviendo en el worktree `.claude/worktrees/fasting-timer`. El checkout principal se quedo donde siempre estuvo, en `master`, y `master` y `main` **no tienen ancestro comun** (`git merge-base` no devuelve nada), asi que nada advertia del desfase. `master` tiene 29 commits; `main`, 52.

**Lo que le faltaba a `master` y por lo tanto a todo lo que se probo esos tres dias:** el fasting timer completo, la pantalla de calendario, la pantalla de perfil, el fix de UTC (`pgTimestamp` + `.toLocal()`), `date_labels.dart` y sus guardias, y 40 de los 47 tests. **La app que Oscar demostro en clase el 2026-08-05 era una version anterior a todo eso.**

**Y el sintoma que costo dos sesiones enteras: `main` ya tenia resuelto el login de Windows desde el 2026-07-31**, con una solucion mejor. `main` usa un servidor loopback HTTP (`lib/core/auth/desktop_oauth_redirect.dart`, el patron RFC 8252 estandar para apps nativas) con un secreto de 128 bits en la ruta del callback. La sesion del 2026-08-04, viendo la pantalla roja de `webview_flutter` en `master`, diagnostico el problema desde cero y lo reimplemento con el esquema `com.clerk.flutter://` mas una entrada en el registro de Windows (`HKCU:\Software\Classes`): **redundante, mas fragil (depende de una ruta de exe fija en el registro) y menos segura (la URL de callback es un literal constante, adivinable por cualquier proceso local; por eso `main` la habia cambiado a una ruta con secreto en el commit `5176c12 fix(auth): make the desktop OAuth callback unguessable`).** Ese trabajo se descarto: quedo guardado en `git stash` por si acaso, no se porto.

**Aprendizaje para no repetir, y es de metodo, no tecnico:** cuando una sesion arranca y el `CLAUDE.md` dice que hay trabajo hecho en otra rama o en un worktree, **verificar con `git branch --show-current` en que rama esta parado el checkout antes de tocar nada**. Es una linea. En este caso el `CLAUDE.md` de `master` incluso decia "la rama local `master` quedo obsoleta... NO se debe mergear sobre `main`" y aun asi tres sesiones seguidas trabajaron sobre ella, porque leer que una rama esta obsoleta no es lo mismo que comprobar en cual estas. Sintoma delator que hubo y se ignoro: el 2026-08-04 se creyo que el login de Windows estaba roto cuando la bitacora del 2026-07-31 decia que estaba arreglado, y se atribuyo la contradiccion a que "el fix nunca se habia aplicado" en vez de a que se estaba mirando otro arbol de codigo.

Lo que si valia de esos tres dias y se conservo, portandolo a `main`: la migracion de Clerk a produccion con dominio propio (entrada del 2026-08-02), el aprendizaje de `auth.protect()` respondiendo 404 (entrada del 2026-08-05), el cron de keep-alive de Supabase, la regla de emojis, el backlog de notificaciones, y la confirmacion de que el wizard de onboarding funciona con una cuenta nueva.

### 2026-08-05 - Login de produccion verificado end-to-end; el fallo real era la cadena del backend local

**Aviso: esta sesion corrio sobre `master`, ver la entrada de cierre de arriba. El diagnostico de configuracion sigue siendo valido; la parte de codigo (el fix de deep link con `com.clerk.flutter://`) se descarto porque `main` ya tenia una solucion mejor.**

Contexto: el dia de la presentacion, al tocar "Continue with Google" el navegador abria, Oscar elegia su cuenta, autorizaba abrir la app, y entonces el navegador se quedaba cargando infinito mientras la app mostraba "se produjo un error" con un boton de reintentar. Diagnostico inicial natural y equivocado: "el login sigue roto".

**El login no estaba roto.** La pista decisiva fue puramente de codigo, sin reproducir nada: el unico error a pantalla completa con boton "Reintentar" que existe en la app es `_OnboardingGate` (`lib/app/router.dart`), y ese widget cuelga de `signedInBuilder` del `ClerkAuthBuilder`, o sea **solo se renderiza si la sesion de Clerk ya esta activa**. Si el usuario lo esta viendo, el login ya ocurrio y lo que fallaba era la llamada siguiente, `GET /api/onboarding/status`. El navegador cargando infinito es cosmetico: la pagina de callback ya entrego el control a la app y no se cierra sola. **Aprendizaje de metodo generalizable: antes de creer que "el login fallo", mirar que pantalla concreta muestra el error y de que rama del arbol de widgets cuelga - eso solo acota el problema a un lado u otro de la autenticacion sin tocar el dispositivo.**

Tres problemas apilados, todos de configuracion, ninguno en Dart:
1. **No habia backend corriendo.** Puerto 3002 muerto. El unico `node` vivo estaba en 3001 y no era `nutriflow`.
2. **`API_BASE_URL` apuntaba a la IP LAN (`http://192.168.100.130:3002`) y esa ruta hace timeout desde la propia maquina** porque el firewall de Windows bloquea el entrante en 3002. Se cambio a `http://localhost:3002`, correcto para una demo de Windows desktop. **Para volver a probar en el Galaxy A55 hay que devolverlo a la IP LAN, y ahi si hay que abrir el puerto 3002 en el firewall.**
3. **`nutriflow/.env.local` seguia con Clerk de TEST (`pk_test_`/`sk_test_`) mientras la app ya firmaba con PRODUCCION (`pk_live_`).** Dos instancias distintas: el backend no podia verificar el JWT. Este era el bloqueante real. Oscar actualizo el par de llaves a `live` el mismo, sin pasarlas por el chat esta vez.

**Aprendizaje grande, y corrige un diagnostico equivocado anterior: `auth.protect()` de Clerk responde 404, NO 401, cuando no puede autenticar una peticion a `/api/*`.** Verificado en el codigo del paquete (`nutriflow/node_modules/@clerk/nextjs/dist/esm/server/protect.js`, `return notFound()`). El `src/middleware.ts` de `nutriflow` corre `auth.protect()` sobre todo `/api/*`, asi que **cualquier peticion sin token valido a cualquier endpoint da 404 aunque el `route.ts` exista perfectamente en disco**. Esto invalida el diagnostico del 2026-08-02 punto 2, que atribuyo unos 404 en `/api/goals` a "un dev server viejo que no recogio los cambios". **No volver a interpretar un 404 en `/api/*` como "el endpoint no existe" sin antes descartar el choque de llaves de Clerk entre cliente y backend.**

**Verificacion con el log real del dev server, no suposicion:** `GET /api/onboarding/status 200` -> `GET /api/foods/selectable 200` -> `POST /api/onboarding/complete 200` -> `GET /api/goals 200`, cero excepciones en la app, y la app arranco ya autenticada sin volver a loguearse (la sesion de Clerk persiste bien en Windows).

**Se cerro de paso un pendiente historico: el wizard de onboarding completo con una cuenta nueva**, que nunca se habia probado end-to-end desde el 2026-07-17. Los 5 pasos corrieron y `POST /api/onboarding/complete` devolvio 200. Salio el wizard porque al migrar de la instancia de Clerk de test a la de produccion el `clerk_id` cambia, asi que para la base de datos Oscar es un usuario nuevo sin perfil: identidad distinta, no datos corruptos.

### 2026-08-02 - Clerk a produccion con dominio propio: cadena completa montada

**Aviso: esta sesion tambien corrio sobre `master`, ver la entrada de cierre del 2026-08-05.**

Oscar registro el dominio el mismo y **eligio el sufijo `.dpdns.org`, no `.qzz.io` que se le habia recomendado** - el dominio real y definitivo es **`nutriflow.dpdns.org`**. Corregir cualquier referencia futura que diga `qzz.io`.

Pasos ejecutados, en orden: (1) dominio delegado a Cloudflare (`sandy`/`hugh.ns.cloudflare.com`), confirmado con `nslookup -type=NS`; (2) registros DNS que pidio Clerk (CNAME `clerk.nutriflow.dpdns.org` -> `frontend-api.clerk.services`, mas los de `accounts` y correo) agregados en Cloudflare con el proxy naranja **desactivado** (DNS only) y verificados en el dashboard de Clerk; (3) Supabase -> Authentication -> Third-Party Auth: el `domain` se actualizo de la instancia de test (`hardy-tortoise-68.clerk.accounts.dev`) a la de produccion; (4) Vercel (proyecto web `nutriflow`, Production): `CLERK_SECRET_KEY` y `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` a valores `_live_`, deploy hecho; (5) `env.json` de este repo (gitignored): `CLERK_PUBLISHABLE_KEY` ahora `pk_live_Y2xlcmsubnV0cmlmbG93LmRwZG5zLm9yZyQ`.

Verificacion de red: `nslookup clerk.nutriflow.dpdns.org` resuelve y `GET https://clerk.nutriflow.dpdns.org/.well-known/jwks.json` devuelve una RSA key valida, o sea Supabase puede bajar el JWKS.

**Aprendizaje:** el error `No suitable key was found to decode the JWT` en Supabase ahora puede tener DOS causas segun cual instancia de Clerk este activa (test vs produccion) - comparar el `domain` configurado en Supabase Third-Party Auth contra el issuer real del token antes de asumir que es el caso de julio.

**Problemas encontrados en el QA del Galaxy A55 esa noche, todos resueltos:**
- **Redirect URL nativo no autorizado.** Las instancias de produccion de Clerk exigen whitelist explicito de redirect URLs (las de test son permisivas). `GET /v1/redirect_urls` devolvia `[]`. Se agrego `com.clerk.flutter://callback` via `POST https://api.clerk.com/v1/redirect_urls`. **Nota para `main`: la solucion de desktop de `main` no usa ese esquema sino un loopback `http://127.0.0.1:<puerto>/clerk-callback/<secreto>`, asi que si el login de escritorio falla contra la instancia de produccion por redirect no autorizado, ese es el primer sospechoso - la whitelist de produccion puede necesitar una entrada para loopback.**
- **Google SSO con las credenciales compartidas de Clerk.** Produccion no las permite (`Missing required parameter: client_id`). Oscar configuro credenciales propias en Clerk (Configure > SSO Connections > Google > "Use custom credentials") reusando el proyecto de Google Cloud de la web.
- **Fallo de DNS especifico del telefono.** El login se completaba en Google pero la app volvia sola al login sin error. El log mostraba, **en el arranque** (no al tocar el boton), `Failed host lookup: 'clerk.nutriflow.dpdns.org'` al pedir `/v1/client`, mientras la PC resolvia bien en simultaneo: cache negativa del resolutor del telefono mientras propagaban los registros. **Un DNS que falla al arrancar deja el cliente de Clerk mal inicializado para el resto de esa sesion de la app**, aunque el dominio resuelva bien un minuto despues; hay que reiniciar la app entera, no reintentar el boton.

**Nota de seguridad:** en un punto Oscar pego la `CLERK_SECRET_KEY` de produccion completa en el chat (`sk_live_oTmb...`) tras rechazar la alternativa de correr el comando el mismo. Se uso una vez y se le recomendo rotarla; **al 2026-08-05 sigue sin rotar**. Nunca pedir ni aceptar una secret key en el chat si se puede evitar: la alternativa correcta es darle el comando exacto para que lo corra en su terminal.

### 2026-08-01 - Dominio gratuito para Clerk produccion + cron de keep-alive de Supabase

**Correccion sobre el repo que Oscar dio (`DigitalPlatDev/Domain-OSS`): ese NO es el repo que reparte dominios gratis.** Es una plataforma de gestion de DNS autohospedada; su propio README dice "not a registrar, registry, billing platform". El repo real de la misma organizacion es **`DigitalPlatDev/FreeDomain`** (dashboard en `dash.domain.digitalplat.org`, login con GitHub). Si vuelve a mencionarse "Domain-OSS" para pedir un dominio gratis, aclarar esta confusion antes de seguir.

Sufijos que reparte FreeDomain: `.dpdns.org`, `.qzz.io`, `.qd.je` (2 puntos con el nombre del proyecto) y `.us.kg`/`.xx.kg` (3 puntos). No hay opcion de 1 solo punto. Se recomendo `nutriflow.qzz.io`; **Oscar termino eligiendo `nutriflow.dpdns.org`** (ver entrada del 2026-08-02).

**Cron de keep-alive de Supabase: creado `.github/workflows/supabase-keepalive.yml`.** GitHub Actions con `schedule: cron "0 8 */3 * *"` (cada 3 dias, dentro de la ventana de ~7 dias que usa Supabase para pausar proyectos free) mas `workflow_dispatch` para dispararlo a mano. Hace un `curl` con la anon key contra `GET /rest/v1/`: no toca ninguna tabla ni depende de RLS. La anon key va embebida directo en el YAML, no como secret de GitHub, a proposito: no es un dato sensible, ya viaja dentro del APK, y la seguridad real la da RLS. **Sin commitear ni pushear todavia** - activar un workflow en el repo publico consume minutos de Actions y queda visible, asi que espera confirmacion de Oscar.

### 2026-08-01 (cierre) - Repo publicado, y la limpieza de historial que hubo que hacer antes

El repositorio ya esta publico: **https://github.com/oscarjnz/nutriflow_mobile**, rama `main`, tag `v0.1.0`, MIT. Se subio solo el codigo fuente; el APK espera al backend en HTTPS.

**Lo que hubo que limpiar antes del push, y por que no bastaba `git rm`.** La auditoria previa (`env.json` nunca rastreado, ningun patron de llave en ningun blob del historial) salio limpia, pero encontro dos cosas que no eran secretos tecnicos sino datos personales:

1. `docs/entrega/` (documentacion del curso: nombre completo, matricula, nombre del docente, 26 capturas), commiteada en `50839a9`.
2. **El correo de autor de los 51 commits era `ojimenez6@est.unibe.edu.do`**, su correo universitario, visible en cada commit de un repositorio publico. Esto es facil de pasar por alto porque no esta en ningun archivo: vive en los metadatos del commit.

Oscar fue tajante al preguntarle: "Nunca subas nada que tenga que ver con estas cosas jamás". Como dejar de rastrear un archivo no lo borra del historial, se reescribio la historia completa con `git filter-repo` (`--invert-paths --path docs/entrega`, `--replace-text` para las menciones academicas que quedaban en `CLAUDE.md`, y `--mailmap` para el correo, ahora `169315935+oscarjnz@users.noreply.github.com`).

**Como se hizo sin arriesgar el trabajo, que es lo reutilizable:** bundle de respaldo de todos los refs primero (`git bundle create ... --all`), clon **desde ese bundle** a un directorio temporal (asi el respaldo queda validado de paso, no solo creado), reescritura sobre el clon, y recien despues las verificaciones: cero commits tocando la ruta purgada, cero blobs con las cadenas sensibles, un solo correo de autor, y `git ls-tree -r HEAD` identico entre el arbol reescrito y el local (los blob hashes son de contenido, asi que iguales significa byte a byte). Solo entonces se hizo push, y el repo local se apunto a `origin/main`. El repo original nunca se toco hasta tener la verificacion en mano.

**Consecuencia permanente:** la rama local `master` (`c765923`) quedo colgando de una historia que ya no existe en remoto. No mergearla nunca sobre `main`.

Tambien se agregaron al `.gitignore`, por adelantado, `android/key.properties`, `*.jks` y `*.keystore`, para que la keystore de release sea imposible de commitear por accidente cuando exista.

### 2026-08-01 - Licencia MIT elegida, y el plan de publicacion (GitHub Releases -> Google Play) con lo que implica pasar Clerk a produccion

Oscar confirmo **MIT** (era lo que queria decir con "una de esas cosas de github como Harvard"). `LICENSE` escrito en la raiz con el texto MIT estandar, copyright 2026 a su nombre. Con eso el repo ya se puede hacer publico como open source; sin `LICENSE` un repo publico es "todos los derechos reservados" por defecto y nadie puede usarlo legalmente.

**Estrategia de release acordada:** GitHub Releases primero (gratis, inmediato, sirve de canal de distribucion real via APK descargable), Google Play despues (25 USD una vez + test cerrado de 12 testers por 14 dias para cuentas personales creadas despues del 2023-11-13, que es el caso de Oscar). Versionado **SemVer** en `pubspec.yaml` (`version: X.Y.Z+N`), donde `N` (el `versionCode` de Android) **solo sube, nunca se repite ni baja** - Play rechaza un `versionCode` ya usado y esa es la restriccion mas rigida de todo el proceso. Tag de git `vX.Y.Z` por release, y el APK adjunto al release de GitHub.

**Lo que cambia al pasar Clerk de development a production, verificado en la doc oficial (no es un flag, es una instancia nueva):**
- Se necesita **dominio propio + registros DNS** (`clerk.<dominio>`), llaves nuevas `pk_live_`/`sk_live_`, y **credenciales propias de Google OAuth** (en development Clerk presta unas compartidas que no sirven para produccion).
- **Los usuarios NO se migran.** Un mismo humano recibe un `clerk_id` distinto en la instancia de produccion, asi que su fila en `users` (mapeada por `clerk_id`) no lo reconoce: entra como usuario nuevo y vuelve a pasar el onboarding. Los datos viejos quedan huerfanos, no se pierden pero tampoco se ven.
- **El `iss` del JWT cambia**, asi que hay que actualizar el domain en Supabase -> Authentication -> Third-Party Auth el mismo dia, o todo el CRUD directo empieza a dar `401 - No suitable key was found to decode the JWT`. Es exactamente el fallo de la entrada del 2026-07-10, que ya nos costo una sesion entera.
- Los redirect URLs del OAuth (`com.clerk.flutter://callback` en movil, `http://127.0.0.1:<puerto>/...` del flujo RFC 8252 de escritorio) hay que volver a permitirlos en la instancia de produccion; production valida esa lista, development es permisiva.

### 2026-08-01 - Fasting timer (Fase 3): implementacion, 4 defectos corregidos, y validacion contra la base viva

Se ejecutaron las 7 tareas del plan `docs/superpowers/plans/2026-07-31-fasting-timer.md` con `superpowers:subagent-driven-development` en la rama `worktree-fasting-timer`. Alcance v1: elegir protocolo, iniciar, ver el progreso en vivo, terminar o cancelar, e historial reciente. **Rachas (`user_streaks`) quedaron fuera de alcance a proposito** - no se toco esa tabla.

**Arquitectura:** CRUD directo contra `fasting_sessions` via `supabase_flutter` (CLAUDE.md seccion 6), mismo patron que `WeightLogsRepository`. Lecturas (`fetchActive`, `fetchHistory`) pasan por `cachedFetch`, asi que la pantalla funciona sin conexion con el mismo banner de "sin conexion" que el dashboard. `startFast` resuelve el `user_id` con el RPC `app_user_id()` y genera el `id` client-side con `uuid` v4.

**Cuatro defectos reales encontrados por revision y corregidos** (los tres primeros los habia mandado el propio texto del plan; la correccion goberno sobre el plan):
1. **El id de protocolo se filtraba crudo a la UI.** `custom` aparecia literal en pantalla en vez de "Personalizado". Se agrego `_getProtocolLabel`, que resuelve id -> etiqueta y cae al id crudo solo si el protocolo no existe (dato de una version futura o inconsistente).
2. **"Terminar" y "Cancelar" no eran mutuamente excluyentes.** Se podian disparar los dos, dejando `end_at` y `deleted_at` en la misma fila: el ayuno quedaba terminado pero invisible en el historial (que filtra `deleted_at is null`). Ahora cada boton se deshabilita mientras el otro corre (`ending || canceling`).
3. **Faltaban guardas `mounted` tras varios `await`**, incluido el `showDialog` de confirmacion de `cancelFast` (el usuario puede salir de la pantalla con el dialogo abierto).
4. **Un `try`/`catch` silenciaba errores en `getProtocolLabel`**, violando la regla de la seccion 9. Se quito en una ronda posterior: la funcion es pura y no puede lanzar.

**Gotcha real de `cachedFetch` con tipos `T` nulleables (documentado en el codigo, vale para cualquier feature futura):** `fetchActive()` devuelve `CachedValue<FastingSession?>`, y "no hay ayuno activo" es un valor legitimo. Si el `fetchRaw` devolviera `null` directo, el cache guardaria `null`, y el camino de fallback de `cachedFetch` trata un `null` cacheado igual que "nunca se cacheo nada" - o sea, ante una caida de red hubiera re-lanzado el error en vez de responder correctamente "no hay ayuno activo, desde cache". Se resolvio guardando `{}` en vez de `null` y decodificando el mapa vacio como `null`. **Cualquier provider futuro cuyo `T` sea nulleable necesita el mismo cuidado.**

**Validacion contra la base de datos viva (proyecto `drvijhxhthadzitvnitz`, no solo contra el codigo), porque el repositorio depende de invariantes que viven en Postgres y no en Dart:**
- `fasting_active_per_user` existe y es exactamente `CREATE UNIQUE INDEX ... ON fasting_sessions (user_id) WHERE end_at IS NULL AND deleted_at IS NULL`. Es la unica fuente de verdad de "un ayuno activo a la vez"; el cliente NO duplica esa regla, solo traduce el error 23505 a "Ya tienes un ayuno en curso." via `curatedFastingError`.
- `fasting_sessions_protocol_check` permite exactamente `12:12, 14:10, 16:8, 18:6, 20:4, custom` - coincide 1:1 con `fastingProtocols` en Dart. **No existe OMAD** en esta tabla, aunque suene natural para un feature de ayuno; no agregarlo al cliente sin migrar el constraint primero.
- `fasting_sessions_target_hours_check` es `> 0 and <= 72`, coincide con `parseCustomTargetHours` (1-72).
- `target_hours` es `integer`, no `numeric`: por eso `as int` es seguro aqui y NO hace falta `numFromPostgrest` (ver la trampa de columnas `numeric` en la entrada del 2026-07-17). `start_at`/`end_at` son `timestamptz`, llegan como ISO string y `DateTime.parse` los cubre.
- RLS esta habilitada con politicas para las 4 operaciones, todas `user_id = app_user_id()`. Por eso las queries del repositorio **no llevan filtro `user_id` explicito** y aun asi no filtran datos de otros usuarios; `endFast`/`cancelFast` filtran solo por `id` y la policy de UPDATE los acota al dueno.

**Verificacion:** `flutter analyze` 0 errores (7 infos preexistentes, ninguno nuevo), `flutter test` 33/33, `build_runner` regenero contenido identico (solo diffs CRLF/LF por el checkout de Windows), `flutter build apk --debug` y `--release` limpios.

### 2026-08-01 (cierre) - Revision final del branch: el bug de UTC que hacia mal la cuenta desde el primer segundo

Revision de todo el branch con `superpowers:requesting-code-review`, en dos revisores paralelos (uno para el fasting timer, otro para el trabajo de auth/fechas/navegacion del 2026-07-31). Salio un defecto critico que ninguna de las rondas anteriores habia visto, mas cuatro importantes.

**CRITICO, y la trampa mas util de todo el proyecto hasta ahora: se escribian marcas de tiempo como hora de pared local en columnas `timestamptz`.**

`DateTime.toIso8601String()` **solo agrega el sufijo `Z` si el `DateTime` ya es UTC**. Un `DateTime.now()` local se serializa como `2026-08-01T20:00:00.000`, sin offset ninguno. Y el `TimeZone` de sesion de Supabase es `UTC` (verificado con `show timezone`), asi que Postgres lee ese literal como si ya fuera UTC. Para un usuario en Santo Domingo (UTC-4) eso guarda un instante **cuatro horas en el pasado**. Verificado contra la base viva, no razonado en abstracto:

```sql
select '2026-08-01T20:00:00.000'::timestamptz  as lo_que_se_guardaba,   -- 2026-08-01 20:00:00+00
       '2026-08-02T00:00:00.000Z'::timestamptz as lo_correcto,          -- 2026-08-02 00:00:00+00
       ('2026-08-02T00:00:00.000Z'::timestamptz - '2026-08-01T20:00:00.000'::timestamptz); -- 04:00:00
```

Se veia en el fasting timer porque es lo unico que calcula una duracion contra `now()`: **un ayuno recien iniciado mostraba "4h 0m" de entrada**, y la barra de progreso daba por cumplido un tercio de un 12:12 antes de que el usuario ayunara un minuto. Pero el mismo defecto corrompia en silencio `weight_logs.logged_at` y, en `fetchEntriesForDay`, **toda la ventana del dia**: las comidas registradas despues de las 20:00 locales caian en el dia siguiente.

**Y habia un segundo bug que tapaba al primero.** Al leer, `DateTime.parse` de una fecha con offset devuelve un `DateTime` **UTC**, cuyos `.day`/`.hour` son componentes UTC. O sea que el historial se fechaba por el calendario de UTC. Los dos errores se cancelaban y por eso las fechas "se veian bien": **arreglar uno solo habria hecho visible el error en vez de corregirlo**, por eso ambos lados tuvieron que cambiar en el mismo commit.

Solucion: `lib/core/supabase/pg_timestamp.dart` con un unico helper `pgTimestamp(DateTime)` (`value.toUtc().toIso8601String()`), usado por los tres repositorios que escriben, y `.toLocal()` en cada mapeo de fila. **Regla dura de aqui en adelante: nunca llamar `toIso8601String()` directo sobre algo que va a la base; siempre `pgTimestamp`.** Tests de regresion en `test/pg_timestamp_test.dart` que afirman que la salida termina en `Z` y que el instante se preserva.

**Detalle de Dart que hay que recordar:** `DateTime.==` compara el instante **y** el flag `isUtc`, asi que al agregar `.toLocal()` los tests viejos que hacian `expect(session.startAt, DateTime.parse('...Z'))` empezaron a fallar. Lo correcto en estos casos es `isAtSameMomentAs`, no `==`.

**Los otros hallazgos atendidos:**
- **Los fallos de "Terminar" y "Cancelar" eran invisibles.** `_error` se seteaba pero solo se renderizaba dentro de `_StartFastCard`, que esta fuera de pantalla justo cuando hay un ayuno activo. Las dos acciones con mas probabilidad de fallar en un telefono fallaban sin decir nada. Ahora la tarjeta activa tambien muestra el error, y se limpia al reintentar.
- **El cronometro no tenia cifras tabulares** (`displaySmall` no las trae; solo `displayLarge` las define en `typography.dart`). Es el unico numero que cambia cada segundo, justo el caso para el que existe la regla de la seccion 5.
- **`debugPrint` escribe tambien en release**, y `desktop_oauth_redirect.dart` registraba el query completo del callback, que lleva el token de handshake de Clerk. Ahora solo registra la ruta.
- `formatFastingDuration` no acotaba duraciones negativas (`inMinutes.remainder(60)` conserva el signo, daba "-2h -30m"); `fastingProtocolLabel` se movio junto a `fastingProtocols` para poder testearlo.

**PENDIENTE CONOCIDO, no arreglado aqui a proposito: el cache local no esta segmentado por usuario.** Las claves son constantes globales (`fasting_active`, `fasting_history`, `goal`, `today_meals`, `weight_logs_recent`) y nada limpia la base Drift al cerrar sesion. Si un segundo usuario inicia sesion en el mismo dispositivo y se queda sin conexion, el fallback de `cachedFetch` le entrega los datos del primero, incluyendo el campo libre `notes` de los ayunos. **Las RLS protegen la red, no el cache local.** Es un problema preexistente y sistemico (afecta igual a features ya mergeadas), y no se toco porque el arreglo correcto no es de una linea: `signedOutBuilder` es un builder de widget, asi que limpiar ahi dispararia en cada rebuild; hace falta un listener de transicion de sesion, o prefijar cada clave con el `app_user_id()` resuelto. Merece su propio cambio enfocado.

### 2026-07-31 (noche) - Primer APK release instalado en el Galaxy A55

Oscar pidio instalar la app en su telefono (conectado por USB). Se compilo desde el worktree `fasting-timer` (la rama con el trabajo mas completo: login de Windows, calendario, perfil) un APK **release**, no debug, para que quede instalada de forma permanente y usable sin `flutter run`: `flutter build apk --release --dart-define-from-file=env.json` + `flutter install --release -d R5CX9202W8P`. Firma con las debug keys (ya estaba asi en `android/app/build.gradle.kts`), suficiente para instalacion directa.

**Dos cosas que habrian roto el APK release y no se notan en debug** (el `flutter run` de siempre las tapaba):
1. **`android.permission.INTERNET` solo estaba en `src/debug/AndroidManifest.xml`.** Es el manifest que Flutter genera por defecto, y solo aplica al build type debug. Un APK release habria quedado sin red. Se movio/agrego al manifest `main`.
2. **Cleartext HTTP bloqueado.** Flutter inyecta una network security config permisiva solo en debug; en release, Android 9+ rechaza HTTP en claro, y el backend de `nutriflow` es HTTP plano en la LAN. Se agrego `android/app/src/main/res/xml/network_security_config.xml` (`base-config cleartextTrafficPermitted="true"`, con comentario de cuando quitarlo) referenciado desde el manifest. Es global a proposito y no por dominio: `API_BASE_URL` apunta a la IP LAN de la maquina, que ya cambio dos veces entre sesiones. Supabase y Clerk siguen siendo HTTPS igual.

`env.json` volvio de `http://localhost:3002` (valor correcto solo para la demo en Windows) a `http://192.168.100.130:3002`: la Wi-Fi de la maquina volvio a esa IP, y desde el telefono `localhost` es el propio telefono.

**Verificacion de conectividad, en este orden, para no repetir el diagnostico:** `ping` desde el telefono a la maquina **falla y eso es normal** - Windows bloquea ICMP entrante por defecto, no prueba nada sobre TCP. Lo que si vale es `adb shell 'nc -w 5 <ip> 3002 < /dev/null; echo "EXITCODE=$?"'` (dio 0). Ojo con PowerShell: `$?` dentro de comillas dobles lo expande PowerShell antes de llegar al shell de Android y devuelve `True` en vez del exit code; hay que usar comillas simples. El perfil de la Wi-Fi es `Public` y las reglas de firewall de Node cubren ese perfil, por eso el 3002 es alcanzable sin tocar nada.

Resultado: app corriendo en el A55 sin crashes en logcat, sesion de Clerk ya persistida, y el dashboard cargando datos reales (meta 2840 kcal via `GET /api/goals`, 1071 kcal consumidas, comidas del dia) - o sea, backend REST y Supabase respondiendo desde el dispositivo. **Los 3 archivos tocados aqui (`AndroidManifest.xml`, `network_security_config.xml`, y `env.json` que es gitignored) se suman al trabajo sin commitear de esta rama.**

### 2026-07-31 - Login roto en Windows: 3 causas raiz independientes, + calendario y perfil

Contexto: Oscar reporto que la app "no hace nada" y que necesitaba presentarla en ESTA maquina (Windows) el mismo dia a las 17:00, con hora fija y sin margen. Login con Google se colgaba tras "Permitir"; Sign In y Sign Up no hacian absolutamente nada.

**Eran tres fallos independientes, ninguno relacionado con el otro:**

1. **`webview_win_floating` no puede completar el OAuth de Clerk en Windows, por construccion.** Su handler nativo de `NavigationStarting` salta la notificacion a Dart cuando `isRedirected == TRUE` o la request es POST (`my_webview.cpp`, ~linea 205). El callback `com.clerk.flutter://callback` llega justamente como redirect 302 posterior al POST del formulario de consentimiento, asi que `onNavigationRequest` NUNCA se dispara, el `showDialog` de `ssoSignIn` no retorna nunca y `ClerkOAuthPanel._connection` queda fijo, dejando el boton deshabilitado para siempre. **Solucion: patron RFC 8252** (navegador del sistema + servidor loopback efimero), en `lib/core/auth/desktop_oauth_redirect.dart`, cableado via `redirectionGenerator` + `deepLinkStream` en `bootstrapClerk`. Se verifico ANTES de escribir Dart, con un probe HTTP directo a la FAPI de Clerk, que la instancia acepta un `redirect_url` a `http://127.0.0.1:PUERTO/...`. Solo aplica en escritorio; movil conserva el webview in-app que ya funcionaba.
2. **Faltaba `ClerkErrorListener` en el arbol, y sin el `clerk.Auth.handleError` es literalmente `throw error`.** Ese throw lo captura y descarta `safelyCall`, y el panel de sign-in ademas pasa su propio `onError` que solo limpia el formulario. Resultado: todo error de validacion (contrasenas que no coinciden, correo ya registrado, credenciales malas) desaparecia sin dejar rastro. **Solucion: `lib/core/auth/clerk_error_display.dart` montado en `MaterialApp.builder`**, el unico punto que queda a la vez debajo de `ClerkAuth` y de un `ScaffoldMessenger`. Se agrego `clerk_auth` como dependencia directa (se importa `ClerkError`/`ClerkErrorCode`).
3. **El proyecto de Supabase estaba `INACTIVE`** (auto-pause del plan free por ~1 semana sin trafico). El backend devolvia 500 con `PostgresError: (ENOTFOUND) tenant/user postgres.drvijhxhthadzitvnitz not found` en `/api/onboarding/status`, y la app mostraba un generico "No pudimos verificar tu perfil". Oscar lo reactivo desde el dashboard (el MCP de Supabase tiene `restore_project` pero el clasificador de permisos lo bloqueo).

**Ademas, dos trampas de entorno que habrian tumbado la demo igual:** la IP LAN de la maquina cambio de `192.168.100.130` a `172.29.4.128`, y `env.json` seguia apuntando a la vieja (se cambio a `http://localhost:3002`, inmune a cambios de IP, correcto para la demo en esta maquina; para probar en el telefono hay que devolverlo a la IP LAN). Y el server de `nutriflow` no estaba corriendo. **Falsa alarma que costo tiempo y no debe repetirse:** los 404 de `/api/*` sin token NO son un endpoint faltante, son `clerkMiddleware` + `auth.protect()` haciendo su trabajo; `/sign-in` responde 200 y confirma que el server esta sano.

**Trabajo de producto de la misma sesion:** el selector de dias del dashboard dejo de ser decorativo. `lib/shared/date_labels.dart` (tablas de dias/meses en espanol escritas a mano en vez de `intl`, para no depender de un `initializeDateFormatting` asincrono que si falla devuelve ingles en silencio), `MealLogsRepository.fetchEntriesForDay` + `mealEntriesForDayProvider`/`macroTotalsForDayProvider` (family, cache key por dia), pantallas nuevas `features/calendar/` y `features/profile/` con rutas `/calendar` y `/profile`, y `_GateErrorScreen` que traduce el codigo de estado en la accion que lo resuelve en vez de un mensaje ciego. `flutter analyze` 0 errores, `flutter test` 33/33.

**Documentos de presentacion:** se generaron con `python-docx` dos DOCX en APA 7 (informe tecnico con anexo de capturas, y guion de exposicion de 20 min), mas un script de PowerShell que graba una rafaga de capturas de la ventana de la app mientras el usuario la recorre (no hay forma de manejar una app de escritorio de Windows desde aqui, y pedir una captura por turno es inviable). **Esos archivos viven en `docs/entrega/` en el disco de Oscar pero estan fuera del control de versiones a proposito** (ver `.gitignore`): llevan datos personales suyos y de terceros, y el repositorio es publico. Regla permanente: nada de ese tipo se versiona nunca.

**Aprendizaje transversal:** los tres fallos de login se diagnosticaron leyendo codigo fuente de dependencias (C++ de `webview_win_floating`, Dart de `clerk_flutter`/`clerk_auth`) y probando la API real con HTTP directo, no cambiando cosas a ver que pasaba. En los tres casos la correccion fue corta y el diagnostico fue todo el trabajo.

### 2026-07-30 - Weight logs + cache local de lectura: cierre de la Tarea 10 (verificacion final)

Contexto: la sesion anterior (mismo dia, rama `worktree-weight-logs-local-cache`) ejecuto las Tareas 1-9 del plan `docs/superpowers/plans/2026-07-30-weight-logs-local-cache.md` (dependencias, cache Drift, `cachedFetch`, retrofit de `MealLogsRepository`/`goalProvider`, `WeightLog`/`WeightLogsRepository`, `WeightLogScreen`, ruta `/weight`) y las dejo todas commiteadas, pero la Tarea 10 (verificacion final: analyze completo, test suite completo, confirmar codegen al dia, build de APK, QA manual, actualizar esta bitacora) nunca se corrio ni se commiteo. Esta entrada la cierra.

Se corrio, en orden:
- `flutter analyze` (proyecto completo): 0 errores, 7 infos de estilo preexistentes (ninguno nuevo bloqueante - los 4 nuevos son `use_null_aware_elements` en `weight_logs_repository.dart`, cosmeticos).
- `flutter test`: 7/7 tests pasan (`test/postgrest_numeric_test.dart` x3, `test/cached_fetch_test.dart` x4).
- `dart run build_runner build --delete-conflicting-outputs`: 0 archivos escritos - confirma que el codegen de Tareas 3 y 7 (Drift, freezed de `WeightLog`) ya estaba generado y commiteado, nada quedo desincronizado.
- `flutter build apk --debug`: compila limpio, `sqlite3_flutter_libs` (el plugin nativo nuevo de esta feature) enlaza sin problema. Unico warning es el ya conocido de Kotlin Gradle Plugin en `mobile_scanner`/`passkeys_android`/`ua_client_hints` (preexistente, no de esta feature).

**No se pudo completar el ultimo paso de la Tarea 10 (QA manual en dispositivo fisico):** `flutter devices` en esta maquina solo listo Windows desktop, Chrome y Edge - sin Android fisico ni emulador conectado en esta sesion. Segun la bitacora del 2026-07-17, ninguno de esos tres entornos sirve para probar un flujo que toque Clerk+Supabase de punta a punta (Windows no tiene `webview_flutter`, Chrome/Edge no tienen `path_provider` que usa `clerk_flutter`). **Queda pendiente para la proxima sesion con el Galaxy A55 conectado:** guardar un peso (con y sin composicion corporal), confirmar que aparece en el historial y actualiza la card de "ultimo registro" con el delta, y forzar el banner de "sin conexion" apagando la red con datos ya cacheados (tanto en el dashboard como en la pantalla de peso).

**Aprendizaje para no repetir:** cuando un plan de `superpowers:writing-plans`/`executing-plans` tiene una tarea final de "verificacion completa + actualizar bitacora", no asumir que quedo hecha solo porque las tareas de implementacion anteriores tienen commits - revisar si existe el commit especifico de esa ultima tarea (en este caso, buscar `git log` por el mensaje de commit exacto que el plan prescribe, `docs: update bitacora for weight logs and local read cache`) antes de darla por concluida.

**Bug real encontrado por code review y corregido en la misma sesion (2026-07-30): `cachedFetch` confundia un fallo al escribir el cache con un fallo de red.** Si `fetchRaw()` tenia exito pero `cache.putCache(...)` fallaba (disco lleno, SQLite ocupado), el `catch` unico trataba ambos casos igual: descartaba el valor recien obtenido y devolvia el dato viejo del cache marcado `fromCache: true` - un usuario CON conexion podia ver el banner de "sin conexion" y perder el dato fresco. Ademas, si el JSON cacheado ya no calzaba con el `decode` esperado (por un cambio de modelo futuro), el fallback lanzaba un `TypeError` crudo en vez de comportarse como "no habia nada cacheado". Se separo `fetchRaw`/`decode` del `try` que envuelve `putCache` (ahora en su propio `try/catch` con un callback `onCacheWriteError` nuevo, sin afectar el valor devuelto), y se envolvio el `decode(cached)` del camino de fallback para que un decode fallido re-lance el error de red original en vez de un `TypeError` distinto. Tambien se corrigio que el banner "sin conexion" del dashboard solo miraba `goalProvider.fromCache` e ignoraba que `todayMealEntriesProvider` puede caer a cache de forma independiente - ahora el banner se muestra si cualquiera de los dos vino del cache. 3 tests nuevos en `test/cached_fetch_test.dart` (10 en total, todos pasan). **Aprendizaje:** en cualquier helper que combine "red + cache de respaldo", nunca envolver la escritura al cache en el mismo `try/catch` que la llamada de red - son fallos independientes con respuestas distintas (uno es "estas offline", el otro es "no se pudo persistir, pero el dato que tienes es bueno").

### 2026-07-17 (noche) - Sesion de prueba end-to-end: 5 hallazgos reales, ninguno bloqueante para el codigo de la app

Contexto: Oscar pidio probar el flujo completo de logging y confirmar si se podia pasar a la siguiente fase. Se probaron 4 entornos distintos antes de llegar a uno viable; cada bloqueo encontrado se documenta aqui para no repetir el mismo diagnostico.

1. **Emulador Android (`Medium_Phone_API_36.1`): red virtual rota a nivel de host.** `ip route` mostraba solo la subred local `10.0.2.0/24`, sin ruta por defecto hacia `10.0.2.2` (el gateway del emulador) - por eso cualquier request (Clerk, Supabase, hasta DNS) fallaba con `Failed host lookup`. Ni un soft reboot (`adb reboot`) ni un cold boot completo (`emulator -avd ... -no-snapshot-load`) lo arreglaron; la ruta seguia faltando despues de ambos. Causa mas probable: esta maquina tiene VirtualBox + VMware + WSL/Hyper-V coexistiendo (visible en `ipconfig`), una combinacion que frecuentemente rompe el NAT del emulador de Android en Windows. **No se resolvio a fondo** (requeriria tocar configuracion de virtualizacion del host, fuera de alcance); si vuelve a pasar, no perder tiempo con reboots del AVD, ir directo a probar en un dispositivo fisico.
2. **Chrome (`flutter run -d chrome`): crash al iniciar.** `MissingPluginException` en `getApplicationDocumentsDirectory` (`path_provider`) - `clerk_flutter`/`ClerkAuthState.create` usa `path_provider` para persistir la sesion, y ese plugin no tiene implementacion web. Esto es una limitacion de la libreria `clerk_flutter`, no de nuestro codigo; no hay roadmap que pida soporte web todavia, no se investigo mas.
3. **Windows desktop (nunca se habia scaffoldeado - se corrio `flutter create --platforms=windows .` esta sesion, `windows/` ya existe y esta commiteado en el proximo commit):**
   - Login con Google se cae con pantalla roja: `webview_flutter` no tiene implementacion para Windows (`A platform implementation for webview_flutter has not been set`). Windows no es target de distribucion (solo Android/iOS en Fase 4), no vale la pena parchear esto.
   - Login con email/password se queda en "loading" indefinido, sin error ni timeout, con una conexion TCP abierta hacia Clerk que nunca cierra. Explicacion mas probable (no confirmada a fondo): Clerk renderiza un widget de verificacion anti-bot que depende de un WebView, inexistente en el target nativo de Windows, asi que la promesa de sign-up nunca resuelve. **Aprendizaje: no usar Windows desktop para probar flujos de auth nuevos de Clerk.** Sirve para UI que no toque auth, una vez ya hay sesion activa (aunque tampoco hay forma facil de persistir sesion entre corridas ahi sin una previa).
4. **Dispositivo Android fisico (Samsung Galaxy A55, conectado por USB, `flutter run -d <serial>`): el unico entorno donde el flujo completo de auth funciono limpio**, incluyendo login con Google. Es el ambiente de referencia para probar cualquier flujo de auth de aqui en adelante.
5. **Bug real (ya corregido) en el device fisico: `goalProvider` (`GET /api/goals`) fallaba con 404 silencioso** (Riverpod guarda el error en el `AsyncValue` pero no lo imprime a ningun lado - violaba la regla propia de "nunca silenciar errores" de la seccion 9, aunque tecnicamente no era un catch vacio). Causa doble:
   - `API_BASE_URL` en `env.json` decia `http://localhost:3000` - en un dispositivo/emulador Android, `localhost` es el propio telefono, no la maquina de desarrollo. Se corrigio a la IP LAN real de la PC (`192.168.100.130`, especifica de esta maquina, no committeada porque `env.json` esta en `.gitignore`).
   - Ademas, el puerto 3000 en esta maquina NO es `nutriflow` - es un proyecto sin relacion (`marvel`, un timeline de MCU) corriendo en paralelo. La instancia real de `nutriflow` estaba en el puerto **3002** (`next dev -p 3002`). Se confundieron ambos por asumir que "algo escuchando en :3000" era el server correcto sin verificar el contenido de la respuesta - **leccion: siempre confirmar con `curl` que el body de la respuesta es realmente la app esperada antes de diagnosticar mas alla, sobre todo en una maquina con varios proyectos Next.js corriendo a la vez.**
   - Se agrego un `debugPrint` permanente en `dashboard_screen.dart` cuando `goal.hasError || totals.hasError`, para que este tipo de fallo silencioso se vea en el log la proxima vez sin tener que instrumentar codigo a mano.
   - `env.example.json` ya no fija un puerto por defecto (antes decia `3000` a secas, lo cual es exactamente el valor incorrecto que causo esta confusion) - ahora es un placeholder explicito para forzar verificar el puerto real de la instancia de `nutriflow` corriendo.

**Conclusion de la sesion (confirmada por Oscar):** con dispositivo fisico + `API_BASE_URL` apuntando al puerto correcto, el flujo de logging (incluyendo el goal del dashboard) funciona de punta a punta. Queda abierto pasar a Fase 3 o 3.5 (ver seccion 8 y "siguiente accion concreta" en la seccion 0).

### 2026-07-10 - Carpeta creada, CLAUDE.md inicial
Se crea `nutriflowMobile/` dentro de `nutriflow/` (temporalmente, hasta que Oscar la mueva fuera como repo hermano). Este archivo es el punto de partida: rol, stack, arquitectura hibrida, tokens de diseno portados, y roadmap con estado real. Todavia no hay codigo Dart ni `pubspec.yaml`; eso arranca en la Fase 2, despues de que la Fase 1 (endpoints REST) exista en el repo web.

### 2026-07-10 - Fase 0 verificada: puente Clerk -> Supabase funcionando
Contexto: para que Flutter pueda leer/escribir datos directo en Supabase respetando RLS por usuario, Clerk debe poder emitir JWTs que Supabase acepte como Third-Party Auth provider.

Lo que se encontro y corrigio:
- Las RLS del repo web (`supabase/migrations/20260613_0011_clerk_rls.sql`, funcion `app_user_id()`) ya leian el claim `sub` del JWT y lo mapeaban al UUID interno via `clerk_id` - no hizo falta tocar SQL.
- El lado Clerk (Connect with Supabase, `role: authenticated` en el session token) ya estaba bien configurado.
- El lado Supabase (Authentication -> Third-Party Auth -> integracion Clerk, proyecto `drvijhxhthadzitvnitz`) tenia un **domain desactualizado** (`stunning-ghost-75.clerk.accounts.dev`, de una instancia de Clerk vieja) que no coincidia con el domain real de la instancia activa (`hardy-tortoise-68.clerk.accounts.dev`). Esto causaba `401 - No suitable key was found to decode the JWT`. Oscar corrigio el domain en el dashboard de Supabase.
- Prueba final (con sesion real de Oscar en `localhost:3000`, token de `window.Clerk.session.getToken()`, llamado directo a `https://drvijhxhthadzitvnitz.supabase.co/rest/v1/user_settings` con ese token): `200 OK`, devolvio exactamente la fila del propio usuario. Sin token (solo anon key): `200 OK` pero 0 filas (bloqueado por RLS como se espera).

**Aprendizaje para no repetir:** si en el futuro Supabase vuelve a rechazar un JWT de Clerk con "No suitable key was found to decode the JWT", lo primero a revisar es que el `domain` configurado en Supabase -> Third-Party Auth coincida EXACTO con el issuer real del JWT (decodificar el JWT y comparar el claim `iss`), no asumir que la integracion vieja sigue apuntando al lugar correcto. Las instancias de desarrollo de Clerk pueden cambiar de dominio (`xxx-xxx-NN.clerk.accounts.dev`) si el proyecto de Clerk se recrea o resetea.

**Como se probo (para repetir el test si hace falta):** desde una pagina logueada de la app (Clerk activo en `window.Clerk`), en la consola del navegador:
```js
const t = await window.Clerk.session.getToken();
fetch("https://drvijhxhthadzitvnitz.supabase.co/rest/v1/user_settings?select=user_id", {
  headers: { apikey: "<anon key>", Authorization: "Bearer " + t }
}).then(r => r.json()).then(console.log);
```
Debe devolver solo la fila del usuario logueado.
