/** @typedef {{load: (Promise<unknown>); flags: (unknown)}} ElmPagesInit */

/** @type ElmPagesInit */
export default {
  load: async function (elmLoaded) {
    const app = await elmLoaded;
    const script = window.document.createElement('script')
    script.setAttribute(
      'src',
      'https://www.googletagmanager.com/gtag/js?id=G-49QJNCEPD2',
    );

    script.onload = function () {
      function gtag() { dataLayer.push(arguments); }
      window.dataLayer = window.dataLayer || [];
      gtag('js', new Date());
      gtag('config', 'G-49QJNCEPD2');
    };

    document.head.appendChild(script);
  },
  flags: function () {
    return "You can decode this in Shared.elm using Json.Decode.string!";
  },
};
