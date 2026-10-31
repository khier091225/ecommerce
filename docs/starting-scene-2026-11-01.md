# Interactive 3D starting scene

The starting page now uses a glazed teal ceramic mug, a hollow cream rim, visible heart latte art, the supplied Smooch logo wrapped around the front, a rounded handle, and a floating cream saucer with a gold edge. Five shaded coffee beans orbit in front of and behind the mug. Fixed studio lights, a soft floor shadow, a restrained orbital accent, and three rising steam wisps give the scene depth while retaining the existing teal/coral identity.

The entrance turns and settles into place over the existing 2.4 seconds. Copy and ORDER NOW remain immediately usable. Mouse hover and horizontal touch drag tilt the scene with bounded spring motion; release, cancellation, and pointer exit return it to rest. Vertical gestures continue to scroll the page. A small exploration hint sits below the scene and disappears for reduced motion.

## Implementation

All application Dart remains in `lib/main.dart`. `CoffeeSceneViewport` owns interaction controllers, cached image/shader resources, and reusable projection buffers. `CoffeeScenePainter` projects a static 2,092-vertex model with 2,912 triangles, applies fixed lighting and perspective, culls hidden faces, and sorts visible triangles by depth. Body, rim, handle, coffee, saucer, and beans share that depth order. The body and rim meet at shared boundaries to avoid overlapping surfaces.

Latte artwork is generated once as a 520 × 512 texture with an opaque white gutter. Solid surfaces sample the gutter while the coffee uses its artwork. This keeps the main geometry in one indexed triangle draw, with another for foreground beans; the curved logo is a separate small textured draw. It avoids splitting the geometry into dozens of material batches. Model topology, textures, shader objects, and typed projection buffers are reused. Only the animated scene leaf rebuilds during motion; the rest of the page stays outside that builder. No runtime package or network asset was added.

The existing 10-second idle clock drives periodic transforms. All orbit harmonics complete their cycle, and steam fades before its path wraps. Motion pauses when the menu covers the start page and when the application leaves the foreground. Reduced-motion preferences show the complete stationary scene, disable interactive movement, and clear existing tilt even when the preference changes while the page is open. Controllers, decoded images, shaders, and temporary vertex objects are disposed by their owners.

The separate loading screen remains removed. The menu route, product catalog, cart, checkout, payment, history, maps, and ordering logic were not changed.

## Validation

- Static analysis: no issues.
- Full Flutter suite: **94 passed**, including six new scene tests in `test/starting_scene_test.dart`.
- Interaction coverage: hover bounds and pointer exit, horizontal drag release/cancel, usable ORDER NOW, vertical scrolling with enlarged text, live reduced-motion changes, and safe zero/small painter bounds.
- Raster coverage: idle phases 0 and 1 render identically; reduced-motion renders remain identical across phase and tilt inputs.
- The catalog source and importer markers remain unchanged; `main.dart` remains the only application Dart source.

- Release web build and Android debug APK: both succeeded after the final rendering/lifecycle changes.
- Browser checks: 320 × 640, 390 × 844, 768 × 1024, and 1440 × 900 layouts; interactive desktop tilt; ORDER NOW navigation; idle animation resuming on Back; visibly changing normal frames and identical reduced-motion frames. No JavaScript page errors were captured.
- `git diff --check`: passed.

Previews: [phone](../artifacts/starting-scene-phone.png), [small phone](../artifacts/starting-scene-small-phone.png), [tablet](../artifacts/starting-scene-tablet.png), [desktop](../artifacts/starting-scene-desktop.png), and [desktop tilt](../artifacts/starting-scene-desktop-tilt.png).

Physical-device frame rates and iOS rendering require device checks; these tests do not establish 60 FPS on every device.
