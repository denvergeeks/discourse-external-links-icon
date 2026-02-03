// discourse-external-links-icon/javascripts/discourse/api-initializers/external-links-icon.gjs

import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("0.11.1", (api) => {
  api.decorateCooked((cookedEl) => {
    addIcons(cookedEl);
  });

  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      mutation.addedNodes.forEach((node) => {
        if (node.nodeType === 1 && node.querySelector("a[href]")) {
          addIcons(node);
        }
      });
    });
  });
  observer.observe(document.body, { childList: true, subtree: true });

  function addIcons(container) {
    const links = container.querySelectorAll("a[href]:not([data-ext-icon])");
    if (!links.length) {
      return;
    }

    links.forEach((link) => {
      link.setAttribute("data-ext-icon", "true");

      const linkUrl = new URL(link.href);

      if (!["http:", "https:"].includes(linkUrl.protocol)) {
        return;
      }

      if (linkUrl.hostname === window.location.hostname) {
        return;
      }
      
      if (link.matches(".mention, .hashtag, [data-user-card], .onebox, .breadcrumb a, .back")) {
        return;
      }

      // THIS IS THE CORRECTED PART:
      // Revert to the manual, reliable SVG creation. This is guaranteed
      // to return a valid Node and has no legacy dependencies.
      const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      svg.setAttribute('class', 'fa d-icon d-icon-up-right-from-square svg-icon svg-string ext-icon');
      svg.setAttribute('aria-hidden', 'true');
      svg.innerHTML = '<use href="#up-right-from-square"></use>';
      
      // This will now work because `svg` is a valid DOM Node.
      link.appendChild(svg);
    });
  }
});
