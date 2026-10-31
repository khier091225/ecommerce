import {test} from 'node:test';
import assert from 'node:assert/strict';
import {configureSocialPreview} from '../tools/configure_web_preview.mjs';

test('social metadata preserves the page and a hosted subpath, without duplicate tags', () => {
  const html = '<head><base href="$FLUTTER_BASE_HREF"><title>Smooch Cafe</title></head><body></body>';
  const output = configureSocialPreview(html, 'https://cafe.example.org/order?unused=yes#menu');
  assert.ok(output.includes('https://cafe.example.org/order/og-image.png'));
  assert.ok(output.includes('<base href="$FLUTTER_BASE_HREF">'));
  assert.equal((configureSocialPreview(output, 'https://cafe.example.org/').match(/property="og:title"/g) || []).length, 1);
  assert.ok(output.includes('name="twitter:image"'));
});

test('social metadata rejects local, insecure and invalid hosting values', () => {
  for (const value of ['http://cafe.example.org', 'https://localhost', 'https://127.0.0.1', 'invalid']) {
    assert.throws(() => configureSocialPreview('<head></head>', value));
  }
});
