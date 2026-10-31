{{flutter_js}}
{{flutter_build_config}}

const boot = document.getElementById('smooch-boot');
const bar = boot?.querySelector('.boot-bar');
const progress = value => { if (bar) bar.style.width = value + '%'; };
const showBootError = error => {
  if (boot) boot.textContent = 'Could not open Smooch Cafe. Please refresh to try again.';
  console.error(error);
};
window.addEventListener('flutter-first-frame', () => boot?.remove(), {once: true});
progress(20);
_flutter.loader.load({
  onEntrypointLoaded: async engineInitializer => {
    try {
      progress(50);
      const runner = await engineInitializer.initializeEngine();
      progress(80);
      await runner.runApp();
      progress(100);
    } catch (error) { showBootError(error); }
  },
}).catch(showBootError);
