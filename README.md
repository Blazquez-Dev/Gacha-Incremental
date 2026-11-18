# Roguelite de defensa con héroes gacha

> Documento de diseño · Versión 0.1 · Noviembre 2026
> Especificaciones acordadas y propuestas por defecto.

## 1. Resumen

Juego móvil en vertical de partidas cortas (3 a 8 minutos). Un único héroe fijo, situado al pie de la pantalla, defiende un portón con barricadas frente a oleadas de enemigos que bajan desde arriba. El héroe dispara automáticamente. Durante la partida se gana experiencia, se sube de nivel y se eligen mejoras. Al terminar, todas las estadísticas de la partida se reinician y se obtiene moneda para hacer tiradas gacha y conseguir más héroes.

**Referencias de género:** Vampire Survivors y Brotato (mejoras por nivel y reinicio por partida), tower defense con un solo defensor, y el modelo de colección de los gacha tipo Genshin.

**Premisas del proyecto:**

- Desarrollo en solitario, sin presupuesto y sin experiencia previa.
- Mínimo trabajo gráfico: la diversión debe venir de la mecánica, no del arte.
- Objetivo: llegar a publicar un juego terminado.

## 2. Plataforma y aspectos técnicos

- **Plataforma principal:** móvil (Android primero; iOS queda para más adelante si el juego funciona).
- **Orientación:** vertical, jugable con una mano.
- **Motor:** Godot 4 (gratuito, sin royalties, lenguaje GDScript). Exportación a Android sin coste.
- **Resolución base:** vertical (por ejemplo 1080x1920) con escalado configurado desde el inicio.
- **Rendimiento:** tope de enemigos simultáneos y partículas ligeras para móviles modestos.
- **Guardado:** local, con un campo de **versión** desde el primer día para poder cambiar el balance sin romper partidas guardadas.
- **Datos de balance:** costes, probabilidades y estadísticas en archivos de datos (JSON o Resources de Godot), no en el código.
- **Pruebas:** exportar a un móvil Android por USB desde el primer prototipo.

## 3. Bucle de juego

1. El jugador elige su héroe antes de la partida.
2. Juega una partida de oleadas con jefes, subiendo de nivel y eligiendo mejoras.
3. Al terminar (victoria o derrota), recibe moneda según hasta dónde llegó.
4. Gasta la moneda en tiradas gacha y en mejoras permanentes.
5. Con nuevos héroes y mejoras, vuelve a jugar, normalmente en etapas más difíciles.

## 4. La partida

### 4.1 Disposición

- El héroe está **fijo en un extremo** de la pantalla (parte inferior en vertical), detrás de un portón con barricadas.
- Los enemigos aparecen por la parte superior y avanzan hacia el portón.
- **Derrota:** el portón o el héroe caen.
- **Victoria:** superar todas las oleadas de la etapa, incluido el jefe final.

### 4.2 Controles

- **Disparo automático** hacia el enemigo más cercano al portón.
- **Botón de habilidad** único, grande y cercano al pulgar, con enfriamiento visible.
- **Tocar un enemigo** para marcarlo como prioritario (opcional, pendiente de probar).

### 4.3 Estructura

- Oleadas con dificultad creciente y un **jefe cada cierto número de oleadas**.
- Se consiguen **puntos de experiencia** al abatir enemigos.
- Al subir de nivel, el jugador elige **una entre 3 mejoras** (velocidad de disparo, daño, vida, etc.).
- Las estadísticas obtenidas **se reinician al terminar la partida**.
- Duración objetivo: **3 a 8 minutos**.
- Al final se concede moneda según el progreso alcanzado.

### 4.4 Barricadas y portón (propuesta por defecto)

- El portón y las barricadas tienen **vida propia**.
- Se pueden **reparar o reforzar** gastando puntos de la partida, lo que obliga a decidir entre mejorar el arma o proteger la defensa.

### 4.5 Estructura de etapas (propuesta por defecto)

- Etapas con final (por ejemplo 10 oleadas con jefe final), en lugar de un modo infinito.
- Superar etapas desbloquea la siguiente y, más adelante, nuevas dificultades o zonas.

## 5. Héroes

Cada héroe tiene tres elementos:

- **Arma:** define su forma de atacar.
- **Habilidad activa:** se usa con el botón, con enfriamiento.
- **Pasiva:** efecto permanente que influye en qué mejoras conviene elegir.

### 5.1 Tipos de arma acordados

| Arma | Comportamiento |
|---|---|
| Metralleta | Ráfagas de disparos |
| Francotirador | Disparo lento de gran daño a un objetivo |
| Escopeta | Abanico de proyectiles de corto alcance |
| Fusil | Disparo constante y equilibrado |

A futuro se podrían añadir otros tipos (área, rayo, rebote, invocaciones) si hacen falta más variaciones.

### 5.2 Mejoras durante la partida

- **Lista general** común a todos los héroes (daño, cadencia, vida del portón, etc.).
- **Mejoras específicas** de cada héroe, ligadas a su arma, habilidad y pasiva.
- *Propuesta por defecto:* posibilidad de **relanzar** las 3 opciones con algún recurso limitado.

## 6. Gacha y duplicados

- Los héroes se consiguen mediante **tiradas gacha** con moneda ganada jugando.
- **Los duplicados mejoran al héroe** y desbloquean sus habilidades, pasivas y mejoras.
- *Propuesta por defecto:* el héroe base ya trae arma y pasiva básica; los duplicados desbloquean de forma escalonada, hasta un máximo de unos 6:
  1. Habilidad activa.
  2. Mejora de la pasiva.
  3. Mejoras de partida adicionales para ese héroe.
  4. Etc., hasta el máximo.
- Se **muestran las probabilidades** de cada rareza (requisito de Google Play y App Store).
- Sistema de garantía (*pity*), rarezas y tabla de probabilidades: se definen cuando el bucle principal ya sea divertido.
- **Sin compras con dinero real** de momento. Si se añadieran más adelante, hay que revisar la normativa sobre *loot boxes* (restricciones por edad y país, y debate legislativo en España y la UE).

## 7. Progresión fuera de la partida

Para que el jugador avance siempre, aunque el gacha no le dé suerte:

- **Moneda de partida:** se gana jugando y se gasta en tiradas.
- **Subida de nivel permanente de cada héroe** con moneda (más daño y vida base). *Propuesta por defecto.*
- **Duplicados:** mejoras permanentes del héroe (ver sección 6).
- **Mejoras permanentes pequeñas** (opcional): árbol de ventajas comprado entre partidas.
- **Desbloqueo** de etapas, jefes y dificultades.
- **Álbum de colección** con los héroes conseguidos.

## 8. Enemigos

- **Enemigo base único** con variaciones de **color** para indicar su dureza (más vida y daño según el color).
- **Jefes** personalizados, cada uno con aspecto y comportamiento propios.
- *Para más adelante:* 2 o 3 comportamientos distintos (rápido, resistente, a distancia) para evitar que las oleadas se vuelvan monótonas.

## 9. Dirección de arte

Objetivo: lograr un aspecto cuidado con el mínimo de trabajo gráfico.

- **Héroes:** un retrato por personaje (selección, tiradas y álbum) y un sprite sencillo para el campo. Generados con IA en local.
- **Enemigos y proyectiles:** formas geométricas de colores.
- **Escenario:** fondo liso o de cuadrícula.
- **Efectos:** partículas, vibración de pantalla y destellos hechos por código ("juice").
- **Paleta:** cerrada, de 4 o 5 colores (por ejemplo de [Lospec](https://lospec.com)), y una tipografía de Google Fonts.
- **Variantes de rareza** por código (shaders, marcos y brillos) para reducir las imágenes necesarias.

### 9.1 Generación de arte con IA (RTX 3060, i5 de 11ª gen)

- Herramientas: **Forge o Automatic1111** para empezar, ComfyUI más adelante.
- Un **único modelo y un LoRA de estilo** para todo el proyecto, con **prompt base fijo** y seed documentada para cada personaje.
- Estilo simple y repetible (silueta, chibi o ilustración plana): el anime muy detallado es difícil de mantener coherente.
- **rembg** para quitar fondos y exportar PNG transparentes del mismo tamaño.
- Verificar siempre la licencia del modelo para uso comercial.

## 10. Audio

- Efectos con **jsfxr**.
- Música con **BeepBox** o packs CC0 de OpenGameArt o itch.io.

## 11. Herramientas (todas gratuitas)

| Para qué | Herramienta |
|---|---|
| Motor | Godot 4 |
| Generación de imágenes | Forge / Automatic1111 / ComfyUI |
| Quitar fondos | rembg |
| Retoques | LibreSprite, Piskel |
| Paletas | Lospec |
| Interfaz e iconos | Packs CC0 de Kenney.nl |
| Sonido y música | jsfxr, BeepBox, LMMS |
| Control de versiones | Git + GitHub |
| Planificación | Notion, Trello o similar |

## 12. Publicación y aspectos legales

- **Pruebas:** repartir el APK por itch.io o directamente a amigos, sin coste.
- **Google Play:** pago único aproximado de 25 $. Las cuentas personales nuevas suelen requerir una fase de pruebas cerrada antes de publicar; comprobar los requisitos vigentes.
- **iOS:** requiere un Mac y unos 99 $ al año. Se deja para más adelante.
- **Divulgación del uso de IA:** declararlo siempre donde la plataforma lo pida.
- **Copyright:** el arte generado íntegramente por IA puede carecer de protección de autor clara. Retocar o componer a mano ayuda.
- **Aceptación del público:** parte de la comunidad rechaza el arte con IA; un estilo coherente y cuidado lo reduce.
- **Propiedad intelectual:** no usar nombres, personajes ni música de terceros. Mundo, personajes y nombres originales.

## 13. Decisiones pendientes

Las propuestas marcadas como "por defecto" se consideran válidas salvo que se cambien.

- **Diseño de las pantallas** (menú, selección, tiradas, álbum).
- **Nombre del juego, ambientación e historia** (aún sin definir).
- **Tabla de rarezas y probabilidades** del gacha, y sistema de garantía.
- **Número de héroes en el lanzamiento:** objetivo realista de 8 a 12.
- **Progreso offline:** no es necesario para el bucle actual; se puede añadir más adelante.
- **Tocar para priorizar objetivo:** decidir tras probarlo en el prototipo.
- **Modelo de monetización**, si finalmente lo hay.

## 14. Plan de trabajo

1. **Aprendizaje:** aprender Godot 4 construyendo el propio prototipo (escenas, nodos, señales).
2. **Prototipo con formas simples** (sin arte): héroe fijo que dispara solo, enemigos que bajan, daño al portón, subida de nivel con 3 mejoras y pantalla de fin. Probado en el móvil.
3. **Datos externos:** estadísticas de enemigos y mejoras en JSON.
4. **Sistema de moneda, gacha y duplicados** con héroes de prueba.
5. **Arte:** definir el estilo, generar los primeros 8 a 12 héroes y sus retratos.
6. **Contenido:** jefes, etapas, álbum, sonido y efectos.
7. **Prueba cerrada** en itch.io y recogida de opiniones.
8. **Publicación** en Google Play.

> **Regla de oro:** si el prototipo con formas simples no es divertido, no lo arreglará el arte. Hay que dejarlo sólido antes de invertir tiempo en lo visual.
