import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.23.0", (api) => {
  const host = window.location.hostname;

  function markExternalLinks(container) {
    container.querySelectorAll("a[href^='http']").forEach((a) => {
      try {
        const url = new URL(a.href);
        if (url.hostname !== host) {
          a.classList.add("ext-link");
        }
      } catch {
        // ignore bad URLs
      }
    });
  }

  api.decorateCookedElement((elem) => {
    markExternalLinks(elem);
  }, { id: "ext-links-icon" });
});
