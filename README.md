# design_system_kmp

## Objetivo
Capa de diseno y runtime UI compartida para componentes KMP/Compose. Centraliza estilos, managers de pantalla/orientacion, recursos y comportamiento visual comun.

## Flujo tecnico principal
1. [Managers](./src/commonMain/kotlin/com/facephi/design_system_kmp/Managers.kt) expone singleton de managers compartidos.
2. Los componentes consumen `screenManager`, `screenOrientationManager`, `resourceManager` y personalizacion externa.
3. En Android, [AndroidScreenOrientationManager](./src/androidMain/kotlin/com/facephi/design_system_kmp/managers/screen/AndroidScreenOrientationManager.kt) aplica bloqueo/restauracion de orientacion.
4. La preferencia de orientacion se modela con [ViewOrientation](./src/commonMain/kotlin/com/facephi/design_system_kmp/managers/screen/ViewOrientation.kt).

## Clases importantes
- [Managers](./src/commonMain/kotlin/com/facephi/design_system_kmp/Managers.kt): punto unico de acceso a managers.
- [ViewOrientation](./src/commonMain/kotlin/com/facephi/design_system_kmp/managers/screen/ViewOrientation.kt): enum de politica de orientacion (`PORTRAIT`, `PORTRAIT_PHONES`, `LANDSCAPE`, `FOLLOW_SYSTEM`).
- [ScreenOrientationManager](./src/commonMain/kotlin/com/facephi/design_system_kmp/managers/screen/ScreenOrientationManager.kt): contrato multiplataforma de lock/reset.
- [AndroidScreenOrientationManager](./src/androidMain/kotlin/com/facephi/design_system_kmp/managers/screen/AndroidScreenOrientationManager.kt): implementacion Android.
- [OrientationPreferences](./src/commonMain/kotlin/com/facephi/design_system_kmp/managers/screen/OrientationPreferences.kt): estado actual de preferencia.
- [ExternalCustomizationManager](./src/commonMain/kotlin/com/facephi/design_system_kmp/managers/externalCustomization/ExternalCustomizationManager.kt): personalizacion externa.

## Dependencias clave
- Externas: Compose Multiplatform, recursos Compose, compottie, colecciones inmutables.
- Consumido por: la mayoria de componentes funcionales.

## Publicacion iOS

Guia detallada:

- [docs/design-system-ios-publish.md](../docs/design-system-ios-publish.md)

### Version unica
- La version iOS de DesignSystem no se gestiona aparte.
- La fuente de verdad es `facephiDesignVersion` en [gradle/libs.versions.toml](../gradle/libs.versions.toml).
- No documentar aqui un valor concreto de version; consultar siempre el catalogo de versiones.

### Recursos Compose namespaced
- La publicacion iOS genera los recursos compilados de Compose bajo el namespace estable:
  `composeResources/com.facephi.design_system_kmp.resources`.
- El task de soporte es:
  `./gradlew :design_system_kmp:prepareDesignSystemResourcesForApplePublication`
- El payload final se deja en:
  `design_system_kmp/build/compose/cocoapods/compose-resources/composeResources/com.facephi.design_system_kmp.resources`
- Este layout replica el contrato de los widgets iOS y evita depender de `strings.xml` crudos en consumidores nativos.

### CocoaPods
- Pod publicado: `FPHIDesignSystemResources`
- Flujo previsto:
  - `DEV/SNAPSHOT`: `.github/workflows/iOS-Design-Publish-DEV-SNAPSHOT.yml`
  - `PRO`: `.github/workflows/iOS-Design-Publish-PRO.yml`
- La publicacion sigue el layout remoto normal:
  - indice en `/.specs/FPHIDesignSystemResources/<version>/FPHIDesignSystemResources.podspec`
  - tarball en `FPHIDesignSystemResources/<version>/FPHIDesignSystemResources-<version>.tar.gz`
- Adicionalmente se agrupa por producto bajo la ruta `DesignSystem/` para simplificar accesos.

### Swift Package Manager
- Repo interno de desarrollo:
  - `facephi/SDK-FPHIDesignSystemResources-SPM`
- Repo cliente/publico:
  - `facephi-clienters/SDK-FPHIDesignSystemResources-SPM`
- El package iOS de DesignSystem es un source package, no un `binaryTarget`.
- El workflow `DEV/SNAPSHOT` publica siempre primero en `facephi`.
- El workflow `PRO` publica en `facephi` y luego sincroniza a `facephi-clienters` mediante el reusable:
  `.github/workflows/reusable_sync_spm_source_repo.yml`
- Este flujo sirve como POC para mover mas packages SPM fuente entre `facephi` y `facephi-clienters` sin cambiar el contenido del package.

### Validacion minima
1. `./gradlew :design_system_kmp:prepareDesignSystemResourcesForApplePublication`
2. `python3 design_system_kmp/scripts/updatePods.py --version=$(python3 design_system_kmp/scripts/readDesignVersion.py) --pod=FPHIDesignSystemResources`
3. `python3 design_system_kmp/scripts/updatePackageSwift.py`
4. `python3 design_system_kmp/scripts/stageSpmSourceRepo.py --destination=<repo_spm_temporal>`
5. `bash design_system_kmp/scripts/verify-compose-resources.sh <repo_spm_temporal>`

## Buenas practicas de mantenimiento
- Cualquier cambio de orientacion o theming puede afectar transversalmente al SDK.
- Mantener compatibilidad de contratos `expect/actual` y evitar APIs Android-only en `commonMain`.
- Validacion minima: `./gradlew :design_system_kmp:build`.
