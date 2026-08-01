# NutriFlow Mobile

Cliente móvil en Flutter para NutriFlow, una aplicación de nutrición que registra comidas en lenguaje natural, sigue macros contra una meta calculada, y acompaña el peso corporal y los ayunos intermitentes.

La app está en español. El código, los identificadores y los comentarios están en inglés.

> **Estado: beta.** Funciona de punta a punta en Android, pero necesita el backend de NutriFlow corriendo y accesible. Todavía no hay una versión publicada en Google Play ni un APK de distribución. Ver [Estado y limitaciones](#estado-y-limitaciones).

## Qué hace

- **Registro de comidas por texto libre.** Se escribe "dos huevos y una taza de avena" y el backend lo interpreta con un LLM; la app muestra los candidatos del catálogo y el usuario confirma los gramos.
- **Registro por código de barras.** Cámara en vivo, resolución del producto contra el catálogo, y confirmación de la porción.
- **Dashboard diario** con calorías y macros consumidos contra la meta, y navegación por día.
- **Onboarding completo** de 5 pasos que recoge perfil, objetivo, actividad, dieta y alimentos disponibles, y genera el plan del usuario.
- **Peso y composición corporal**, con historial y diferencia contra el registro anterior.
- **Temporizador de ayuno intermitente** con protocolos 12:12, 14:10, 16:8, 18:6, 20:4 y personalizado, progreso en vivo e historial.
- **Lectura sin conexión.** Las pantallas principales guardan su última respuesta en SQLite y siguen mostrando datos con un aviso de "sin conexión" cuando la red falla.

## Arquitectura

El cliente es híbrido a propósito, y esa es la decisión de diseño más importante del proyecto:

| Tipo de operación | Cómo se resuelve |
|---|---|
| CRUD simple (comidas, pesos, ayunos, catálogo) | Llamada **directa a Supabase**, filtrada por las políticas RLS del servidor |
| Lógica de negocio (cálculo nutricional, generación de plan, interpretación NLP) | Llamada **HTTP a los endpoints REST** del backend |

**Ningún cálculo científico se reimplementa en Dart.** El BMR, el TDEE, el reparto de macros, la generación del plan de comidas y la conversión de unidades viven en el backend, están testeados ahí, y este cliente los consume. Duplicarlos aquí sería garantizar que las dos implementaciones se desincronicen.

La autenticación es Clerk. El mismo token de sesión sirve para las dos rutas: como `accessToken` al inicializar Supabase (las políticas RLS leen el claim `sub` para resolver al usuario) y como header `Authorization: Bearer` hacia los endpoints REST.

## Stack

| Capa | Tecnología |
|---|---|
| Framework | Flutter (Dart, null-safety estricto) |
| Estado | Riverpod |
| Auth | Clerk (`clerk_flutter`) |
| Datos | `supabase_flutter` (CRUD directo) + Dio (REST) |
| Modelos | freezed + json_serializable |
| Navegación | go_router |
| Caché local | Drift sobre SQLite |
| Cámara | mobile_scanner |
| Iconos | Lucide |

## Cómo correrlo

Requiere Flutter con Dart 3.12 o superior, y una instancia del backend de NutriFlow con su proyecto de Supabase y su aplicación de Clerk.

```bash
flutter pub get

# Configuración local: copiar la plantilla y rellenar los valores reales.
cp env.example.json env.json

# Generar el código de freezed, json_serializable y Drift.
dart run build_runner build --delete-conflicting-outputs

flutter run --dart-define-from-file=env.json
```

`env.json` está en `.gitignore` y **nunca** se versiona. Los cuatro valores que espera son:

| Clave | Qué es |
|---|---|
| `SUPABASE_URL` | URL del proyecto de Supabase |
| `SUPABASE_ANON_KEY` | Clave anónima pública del proyecto (protegida por RLS) |
| `CLERK_PUBLISHABLE_KEY` | Clave publicable de la instancia de Clerk |
| `API_BASE_URL` | Origen del backend REST |

Sobre `API_BASE_URL`: se incrusta en tiempo de compilación, así que cada build apunta al backend que tenía configurado al compilarse. Desde un dispositivo Android físico, `localhost` es el propio teléfono y no la máquina de desarrollo: hay que usar la IP de la red local o una URL pública.

Compilar para Android:

```bash
flutter build apk --release --dart-define-from-file=env.json
```

## Estructura

```
lib/
  app/          Router (go_router), tema, arranque
  core/
    api/        Cliente HTTP tipado hacia los endpoints REST
    auth/       Puente con Clerk, incluido el flujo OAuth de escritorio
    env/        Lectura de la configuración de compilación
    local_db/   Caché de lectura en SQLite (Drift)
    supabase/   Repositorios de CRUD directo
    theme/      Tokens de color, tipografía, radios, sombras y motion
  features/     Una carpeta por feature (dashboard, logging, fasting, ...)
  models/       Modelos freezed
  shared/       Widgets y utilidades transversales
test/           Pruebas unitarias
```

## Pruebas

```bash
flutter analyze
flutter test
```

## Diseño

El sistema visual está portado desde el cliente web del mismo producto, no reinterpretado: misma paleta, mismos radios, mismas curvas de animación. Las sombras nunca usan negro puro, sino un tono cálido derivado del color del texto. Los números se muestran siempre con cifras tabulares. La app respeta la preferencia de reducción de movimiento del sistema.

## Estado y limitaciones

- El backend es un proyecto aparte y todavía no está desplegado públicamente, así que la app necesita que se levante uno propio.
- El build de release se firma actualmente con las claves de depuración. Falta una keystore propia antes de cualquier distribución.
- La caché local no está segmentada por usuario: en un dispositivo compartido y sin conexión, un segundo usuario podría ver los datos guardados del primero. Conocido y pendiente.
- iOS no se ha compilado ni probado. El código no tiene nada específico de Android, pero eso no es lo mismo que estar verificado.

## Licencia

[MIT](LICENSE). Copyright (c) 2026 Oscar O. Jiménez Peguero.
