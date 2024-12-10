// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

import { Hooks as FluxonHooks, DOM as FluxonDOM } from 'fluxon';


let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let Uploaders = {};

Uploaders.S3 = function (entries, onViewError) {
  entries.forEach((entry) => {
    let xhr = new XMLHttpRequest();
    onViewError(() => xhr.abort());
    xhr.onload = () =>
      xhr.status === 200 ? entry.progress(100) : entry.error();
    xhr.onerror = () => entry.error();

    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
        let percent = Math.round((event.loaded / event.total) * 100);
        if (percent < 100) {
          entry.progress(percent);
        }
      }
    });

    let url = entry.meta.url;
    xhr.open("PUT", url, true);
    xhr.send(entry.file);
  });
};

export default Uploaders;
let Hooks = {};

Hooks.ScrollToTop = {
  mounted() {
    this.el.addEventListener("click", () => {
      window.scrollTo({
        top: 0,
        left: 0,
        behavior: "smooth",
      });
    });
  },
};

Hooks.SplitFlap = {
  updated() {
    //codepen.io/jesusbotella/pen/opmRrO
    function makeid() {
      var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

      return possible.charAt(Math.floor(Math.random() * possible.length));
    }

    function randomTime() {
      return Math.round(Math.random() * 200);
    }
    function changeAnimationTime(element) {
      var random = randomTime();
      element.setAttribute("animation-delay", random + "ms");

      console.log("animation-delay", random + "ms");
    }

    var mapFn = function (element) {
      changeAnimationTime(element);
      var i = 0;
      var originalAttribute = element.getAttribute("data-letter");
      var test = [
        makeid(),
        makeid(),
        makeid(),
        makeid(),
        makeid(),
        originalAttribute,
      ];
      element.addEventListener(
        "animationend",
        function () {
          element.setAttribute("data-letter", originalAttribute);
        },
        false,
      );
      element.addEventListener(
        "animationiteration",
        function () {
          element.setAttribute("data-letter", test[i++]);
        },
        false,
      );
    };

    var changingElements = Array.from(
      document.querySelectorAll("[data-letter]"),
      mapFn,
    );
  },
  mounted() {
    //codepen.io/jesusbotella/pen/opmRrO
    function makeid() {
      var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

      return possible.charAt(Math.floor(Math.random() * possible.length));
    }

    function randomTime() {
      return Math.round(Math.random() * 200);
    }
    function changeAnimationTime(element) {
      var random = randomTime();
      element.setAttribute("animation-delay", random + "ms");

      console.log("animation-delay", random + "ms");
    }

    var mapFn = function (element) {
      changeAnimationTime(element);
      var i = 0;
      var originalAttribute = element.getAttribute("data-letter");
      var test = [
        makeid(),
        makeid(),
        makeid(),
        makeid(),
        makeid(),
        originalAttribute,
      ];
      element.addEventListener(
        "animationend",
        function () {
          element.setAttribute("data-letter", originalAttribute);
        },
        false,
      );
      element.addEventListener(
        "animationiteration",
        function () {
          element.setAttribute("data-letter", test[i++]);
        },
        false,
      );
    };

    var changingElements = Array.from(
      document.querySelectorAll("[data-letter]"),
      mapFn,
    );
  },
};

// [!code ++]
let liveSocket = new LiveSocket("/live", Socket, {
// [!code ++] }, }, });

let liveSocket = new LiveSocket("/live", Socket, {
  uploaders: Uploaders,
  params: { _csrf_token: csrfToken },
  hooks: {...Hooks, ...FluxonHooks},
  dom: {
    onBeforeElUpdated(from, to) { FluxonDOM.onBeforeElUpdated(from, to); },
  }
});

// Show progress bar on live navigation and form submits. Only displays if still
// loading after 120 msec
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });

let topBarScheduled = undefined;
window.addEventListener("phx:page-loading-start", () => {
  if (!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 120);
  }
});
window.addEventListener("phx:page-loading-stop", () => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  topbar.hide();
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
