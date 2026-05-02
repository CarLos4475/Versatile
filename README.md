# Versatile

## Badges

![License](https://img.shields.io/badge/license-Private-informational)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![State Management](https://img.shields.io/badge/State%20Management-Riverpod-6C5CE7)
![Database](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white)
![Localization](https://img.shields.io/badge/Localization-ES%20%7C%20EN-4CAF50)
![Storage](https://img.shields.io/badge/Storage-Local%20Only-FF7043)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-111827)
![Architecture](https://img.shields.io/badge/Architecture-Feature%20Based-8E44AD)
![UI](https://img.shields.io/badge/UI-Liquid%20Glass-F4A261)
![Privacy](https://img.shields.io/badge/Privacy-No%20Tracking-2E7D32)

Versatile es una aplicación de seguimiento de entrenamientos desarrollada con Flutter, diseñada para registrar rutinas de gimnasio de forma simple, visual y completamente local. Su enfoque combina una experiencia moderna de uso con herramientas prácticas para planificar sesiones, registrar series y repeticiones, consultar historial y dar seguimiento al progreso sin depender de cuentas, conexión a internet ni servicios de terceros.

Pensada para usuarios que valoran tanto la organización como la privacidad, la app permite construir una biblioteca personal de ejercicios y rutinas, iniciar entrenamientos activos con cronómetro y descansos, y conservar toda la información directamente en el dispositivo.

## Características principales

- Creación y gestión de rutinas personalizadas.
- Biblioteca de ejercicios con búsqueda, filtros por grupo muscular y distinción entre ejercicios base y personalizados.
- Registro de entrenamientos en tiempo real con series, repeticiones, peso y volumen acumulado.
- Soporte para ejercicios bilaterales y unilaterales.
- Historial de sesiones con detalle de rendimiento por entrenamiento.
- Dashboard de inicio con métricas semanales, sesiones recientes y actividad acumulada.
- Onboarding inicial para personalizar la experiencia desde el primer uso.
- Modo claro, modo oscuro y opción de tema del sistema.
- Soporte multilenguaje en español e inglés.
- Exportación, importación y limpieza de datos desde la propia app.
- Almacenamiento 100% local, sin login, sin tracking y sin sincronización externa.

## Enfoque del producto

Versatile busca ofrecer una experiencia de entrenamiento centrada en tres pilares:

- Simplicidad: registrar una sesión debe ser rápido y natural.
- Control: el usuario puede crear su propia estructura de ejercicios y rutinas.
- Privacidad: los datos permanecen en el dispositivo y el uso no depende de una cuenta.

## Capturas de pantalla

Cuando agregues las imágenes, esta sección ya queda lista para GitHub:

```md
## Capturas de pantalla

| Inicio | Rutinas | Entrenamiento activo |
|--------|---------|----------------------|
| ![Home](./docs/screenshots/home.png) | ![Routines](./docs/screenshots/routines.png) | ![Workout](./docs/screenshots/active-workout.png) |

| Ejercicios | Historial | Ajustes |
|------------|-----------|---------|
| ![Exercises](./docs/screenshots/exercises.png) | ![History](./docs/screenshots/history.png) | ![Settings](./docs/screenshots/settings.png) |
```

## Stack técnico

- Flutter
- Dart
- Riverpod para gestión de estado
- SQLite (`sqflite`) para persistencia local
- Internacionalización con `flutter_localizations` e `intl`
- `share_plus` y `file_picker` para exportación e importación de respaldos

## Arquitectura general

El proyecto está organizado alrededor de una estructura clara por capas:

- `lib/features`: pantallas y lógica orientada a cada módulo funcional.
- `lib/domain`: entidades principales de negocio.
- `lib/data`: repositorios, base de datos y datos iniciales.
- `lib/core`: servicios, navegación, tema, utilidades y providers compartidos.
- `lib/shared`: widgets reutilizables de interfaz.

## Módulos funcionales

### Inicio
Pantalla principal con saludo personalizado, próxima rutina sugerida, métricas semanales, volumen acumulado, tiempo promedio de entrenamiento y sesiones recientes.

### Rutinas
Permite crear, consultar y organizar rutinas de entrenamiento con estimación de duración, cantidad de ejercicios y grupos musculares involucrados.

### Ejercicios
Incluye catálogo de ejercicios, búsqueda, filtros por músculo, ejercicios personalizados y soporte para clasificar movimientos unilaterales y bilaterales.

### Entrenamiento activo
Ofrece seguimiento en tiempo real de una rutina en curso con cronómetro, progreso por series, volumen total y temporizador de descanso.

### Historial
Muestra las sesiones realizadas y su detalle para revisar el progreso acumulado a lo largo del tiempo.

### Ajustes
Permite cambiar nombre de usuario, idioma, tema visual y gestionar respaldos locales mediante importación y exportación de datos.

## Privacidad

Uno de los puntos más fuertes de Versatile es su enfoque local-first:

- No requiere crear cuenta.
- No depende de servidores externos.
- No incorpora analítica ni tracking.
- Los datos del usuario permanecen en el dispositivo.

## Instalación

Versatile está planteada para distribuirse mediante releases del repositorio. La idea es que cualquier usuario pueda descargar la versión publicada, instalar el APK y comenzar a usar la aplicación sin configuraciones adicionales ni pasos técnicos.

Cuando la primera release esté disponible, esta sección puede incluir:

- Enlace directo al APK oficial.
- Instrucciones breves de instalación en Android.
- Notas de versión con mejoras y cambios importantes.

## Estado del proyecto

Versatile se encuentra planteado como una base sólida para una app de seguimiento fitness moderna, privada y extensible. El repositorio ya incluye soporte multiplataforma con Flutter y una estructura preparada para seguir evolucionando tanto a nivel visual como funcional.
