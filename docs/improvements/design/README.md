# Smooch Cafe design implementation plans

Prepared on 31 October 2026 (Asia/Manila) using flutter-improve-design. All 25 findings were selected. The application was scanned again and each selected article was fetched in full before the plans were written.

The plans below document the original review. After approval to implement all findings, 24 plans were implemented and the share-preview plan was prepared pending a public hosting URL. Later, the user requested removing the extra loading screen and retaining only the 3D Start Screen; the loading-progress plan is now historical. See [implementation status and verification](implementation.md) and [the latest UI report](../../ui-motion-polish-2026-11-01.md) for subsequent changes. The quoted source in each plan remains a historical baseline.

## Start here

- Read [the selected findings](findings.md).
- Read the implementation report before making further changes; avoid reapplying completed plans.
- Each plan contains current-source quotes, target behavior/code, package needs, steps, checks, protected scope and stop conditions. No article needs to be fetched by the executor.
- The quoted baseline is commit fc76bcd7192c63460df486deb451a5876d17cc09. Plans overlap in lib/main.dart: after executing one, refresh any affected plan's stale excerpts before continuing. The STOP instruction protects completed changes; do not blindly replace an entire import/theme/builder block from an older snapshot.
- All application Dart stays in lib/main.dart. Tests may live in test/. Keep the required ORDER NOW / Navigator.push / MaterialPageRoute flow, catalog/importer, current delivery validation and local order/payment behavior.
- Dependency additions are limited to the relevant article's packages. Reuse shared dependencies when present and let pub add update the lockfile without broad upgrades.
- Device interaction checks are acceptance work for implementation, not claims of device validation during planning.

## Plans

1. [Show useful changes once after an app update](plans/in-app-changelog.md)
2. [Keep the end of scrolling content clear of system controls](plans/safe-area-replacement.md)
3. [Hint that categories and featured picks can scroll sideways](plans/shader-mask.md)
4. [Make selected text and cursors match the cafe theme](plans/selection-color.md)
5. [Prepare cafe images before their first appearance](plans/precache-icons.md)
6. [Keep missing map addresses out of customer text](plans/never-show-null.md)
7. [Make peso totals and quantities easy to read](plans/format-numbers-for-humans.md)
8. [Show the cafe while the browser loads the app](plans/flutter-web-loading-progress.md)
9. [Give important taps and order results subtle tactile feedback](plans/haptic-feedback.md)
10. [Keep changing quantities and totals visually steady](plans/tabular-figures.md)
11. [Give shared app links a cafe preview card](plans/flutter-web-og-image.md)
12. [Get the keyboard out of the way while scrolling checkout](plans/dismiss-keyboard-on-scroll.md)
13. [Return to the top by tapping the active destination](plans/bottom-nav-reselect.md)
14. [Make the installed app version easy to find](plans/show-app-version.md)
15. [Make browser and desktop page changes immediate](plans/web-page-transitions.md)
16. [Show a single scroll-position indicator on long pages](plans/scrollbars.md)
17. [Show readable order dates in the customer's locale](plans/format-date-times.md)
18. [Restore the native iPhone tap-to-top gesture](plans/statusbar-tap-scroll.md)
19. [Bound extreme text sizes while keeping enlarged text usable](plans/text-scale-factor.md)
20. [Let sideways browsing reach the content edges](plans/horizontal-list-padding.md)
21. [Give each browser page a useful tab title](plans/browser-tab-title.md)
22. [Keep search closed after the sort menu is dismissed](plans/unfocus-before-modal.md)
23. [Show a branded fallback if a widget breaks](plans/friendly-error-view.md)
24. [Group Philippine phone numbers while typing and reading](plans/format-phone-numbers.md)
25. [Keep checkout keyboard actions predictable](plans/text-input-action.md)

## Decisions made during the complete scan

- Keyboard actions: contact Next already works, while the address forces Next despite being multiline. Restore newline behavior; do not submit an incomplete order from the phone key.
- Text scaling: use the article's clamp mechanism with a 2.0 maximum, preserving the existing enlarged-text range. Never shrink to 1.0/1.1 to hide a layout failure.
- Bottom spacing: account for safe fixed footers; do not add the physical inset twice.
- Asset warmup: essentials first, remaining images serially in the background; do not block ORDER NOW or enlarge cache limits.
- Web social previews: a real PUBLIC_SITE_URL has not been supplied. That plan has a concrete input gate; do not invent a domain or claim deployment validation.
- Retain the restored Cafe info layout. The version plan adds only a quiet build label at its bottom.
- No new backend, accounts, real payments, rider service, remote release-note service or country picker is part of these plans.

## Validation of this planning output

Check that plans/ contains exactly the selected 25 article-slug Markdown files, every file has all template sections, all Where excerpts match the reviewed source, index links resolve, and git diff --check succeeds. Application checks should be run by each future executor as specified; this documentation-only pass does not need to mutate the project by running them.

