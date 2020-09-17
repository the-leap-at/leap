// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from '../css/app.scss';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'phoenix_html';

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import { Socket } from 'phoenix';
import LiveSocket from 'phoenix_live_view';
import TuiEditor from '@toast-ui/editor';

let Hooks = {};

Hooks.TuiEditor = {
  mounted() {
    let editor = this.el;
    let textarea = document.getElementById(editor.dataset.textareaId);

    let tuiEditor = new TuiEditor({
      el: editor,
      initialEditType: 'wysiwyg',
      height: 'auto',
      minHeight: '300px',
      usageStatistics: false,
      initialValue: textarea.value,
      events: {
        change: function () {
          textarea.value = tuiEditor.getMarkdown();
          const evt = new Event('change', { bubbles: true });
          textarea.dispatchEvent(evt);
        },
      },
    });
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content');
let liveSocket = new LiveSocket('/live', Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});
liveSocket.connect();
