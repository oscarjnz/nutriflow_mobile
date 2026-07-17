# CLAUDE.md - NutriFlow Mobile (Flutter)

> Esta es mi memoria viva y activa para este proyecto. No es documentacion decorativa: es la carta que consulto ANTES de cada respuesta (para saber que ya existe, que decision ya se tomo, que sigue) y actualizo DESPUES de cada respuesta con impacto real (para que la siguiente sesion, mia o de otra instancia, no repita trabajo ni errores). Si algo sale mal una vez, se documenta aqui para que no vuelva a pasar. Esta obligacion es religiosa: en cada proyecto/carpeta donde trabaje debo mantener un archivo asi.

---

## 0. Estado actual (leer esto primero, siempre)

**Carpeta:** ya vive en `C:\Users\oscar\nutriflowMobile` como carpeta hermana independiente de `nutriflow` (repo web). Todavia NO tiene `.git` propio inicializado (`git status` devuelve "not a git repository") - pendiente decidir con Oscar si se inicializa aqui.

**Fase activa:** Fase 2 (setup del proyecto Flutter) sigue en marcha, mas avanzada de lo que la entrada de 2026-07-14 reflejaba. Fase 1 (endpoints REST) sigue HECHA.

**Ultimo hito verificado (2026-07-16, auditoria de estado real):**
- Auth gate YA EXISTE (esto no estaba el 2026-07-14): `lib/app/app.dart` monta `_AuthGate` con `ClerkAuthBuilder`, que rutea a `DashboardScreen` si hay sesion o a `LoginScreen` (`lib/features/auth/login_screen.dart`) si no. `main.dart` sigue montando `ClerkAuth` + `ProviderScope` antes del gate.
- `DashboardScreen` (`lib/features/dashboard/dashboard_screen.dart`) sigue con datos ESTATICOS (dice explicitamente en su doc comment que todavia no esta conectada a Supabase/API), pero ahora se apoya en un set de widgets compartidos nuevo: `lib/shared/widgets/` tiene `bento_metric_card.dart`, `hero_card.dart`, `horizontal_day_selector.dart`, `floating_nav_bar.dart`. Esto es una iteracion visual real ("Sophisticated Playful"), no placeholder.
- `core/api` (api_client, nutriflow_api, providers) y `core/supabase/supabase_bootstrap.dart` siguen como en la fase anterior. `models/macro_goal.dart` (freezed) es el unico modelo hasta ahora.
- Las demas carpetas de `features/` (`logging`, `meal_plan`, `onboarding`, `fasting`, `body_metrics`, `favorites`) existen pero estan VACIAS - son solo el scaffold de carpetas, no hay pantallas todavia.
- `go_router` esta en `pubspec.yaml` (`^14.6.2`) pero NO esta wireado en `app.dart` - la navegacion sigue siendo `MaterialApp` directo con un solo widget de pantalla condicional (`_AuthGate`), sin rutas nombradas ni deep linking todavia.
- Sigue sin `.git` inicializado en esta carpeta (`git status` -> "not a git repository"). Sigue sin tests (`test/` no existe o esta vacio).

**Siguiente accion concreta (decidir con Oscar, 2026-07-16):** con el auth gate ya resuelto, lo que falta para cerrar el "MVP visual" de Fase 2 es (a) conectar `DashboardScreen` a datos reales (Supabase directo para meal_logs del dia + `GET /api/goals` via `NutriFlowApi`) en vez de agregar mas pantallas sobre datos falsos, y/o (b) wirear `go_router` de una vez ya que la dependencia esta instalada pero sin usar, antes de que crezca mas el arbol de widgets y haga la migracion mas cara despues.

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
| 2 | Setup del proyecto Flutter aqui: `supabase_flutter` + Clerk SDK, theme portado, pantallas MVP (login, dashboard, registro manual, ver plan) | **EN CURSO** - stack, theme, auth bridge, API client y `DashboardScreen` (datos estaticos) ya existen; falta auth gate/login, conectar dashboard a datos reales, y las demas pantallas MVP | este repo (`nutriflowMobile`) |
| 3 | Paridad ampliada: onboarding completo, edicion de foods, fasting timer, weight logs, favorites/recipes, offline-first | Pendiente | este repo |
| 4 | Distribucion Android/iOS | Pendiente | este repo |

**Nota de coordinacion entre repos:** la Fase 1 se hace desde una sesion de Claude Code con working directory en `nutriflow` (no aqui), porque toca codigo TypeScript del backend. Cuando ambas carpetas sean hermanas (`nutriflow` y `nutriflowMobile`), cada sesion opera en su propio directorio; hay que traer el contexto manualmente de un lado a otro (memoria + este archivo) porque las sesiones no se ven entre si automaticamente.

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
