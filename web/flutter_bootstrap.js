{{flutter_js}}
{{flutter_build_config}}

const showBootError = error => {
  if (!document.getElementById('startup-error')) {
    const message = document.createElement('main');
    message.id = 'startup-error';
    message.className = 'startup-error';
    message.setAttribute('role', 'alert');
    const title = document.createElement('h1');
    title.textContent = 'Could not open Smooch Cafe.';
    const copy = document.createElement('p');
    copy.textContent = 'Please refresh to try again.';
    const retry = document.createElement('button');
    retry.type = 'button';
    retry.textContent = 'Reload';
    retry.addEventListener('click', () => window.location.reload());
    message.append(title, copy, retry);
    document.body.appendChild(message);
  }
  console.error(error);
};
_flutter.loader.load({
  onEntrypointLoaded: async engineInitializer => {
    try {
      const runner = await engineInitializer.initializeEngine();
      await runner.runApp();
    } catch (error) { showBootError(error); }
  },
}).catch(showBootError);
