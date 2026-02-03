// discourse-external-links-icon/javascripts/discourse/api-initializers/external-links-icon.gjs

import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("0.11.1", (api) => {
  // Use api.decorateCooked to run code on post content after it's rendered
  api.decorateCooked((element) => {
    addIcons(element);
  });

  // Use a MutationObserver to detect when new content is added to the page
  // (e.g., loading more posts, opening popups)
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      mutation.addedNodes.forEach((node) => {
        // We only care about element nodes that might contain links
        if (node.nodeType === 1 && node.querySelector("a[href]")) {
          addIcons(node);
        }
      });
    });
  });
  observer.observe(document.body, { childList: true, subtree: true });

  function addIcons(container) {
    // 1. Guard Clause: Ensure we're working with a valid DOM element.
    // This prevents errors in scenarios like the composer preview.
    if (!container || typeof container.querySelectorAll !== "function") {
      return;
    }

    const links = container.querySelectorAll("a[href]:not([data-ext-icon])");
    if (!links.length) {
      return;
    }

    links.forEach((link) => {
      // Set attribute immediately to prevent reprocessing by other mutations
      link.setAttribute("data-ext-icon", "true");

      const linkUrl = new URL(link.href);

      // 2. Skip non-http/https protocols (e.g., mailto:, tel:)
      if (!["http:", "https:"].includes(linkUrl.protocol)) {
        return;
      }

      // 3. Skip internal links by comparing the hostname to the current site's.
      if (linkUrl.hostname === window.location.hostname) {
        return;
      }
      
      // 4. Skip links inside topic titles to avoid duplicate icons.
      if (link.closest("#topic-title, .topic-title")) {
        return;
      }

      // 5. Skip links that have special Discourse formatting.
      if (link.matches(".mention, .hashtag, [data-user-card], .onebox, .breadcrumb a, .back")) {
        return;
      }
      
      // Manually create the SVG icon to ensure compatibility and avoid legacy APIs.
      const svg = document.createElementNS("http://www.w_3.org/2000/svg", "svg");
      svg.setAttribute('class', 'fa d-icon d-icon-up-right-from-square svg-icon svg-string ext-icon');
      svg.setAttribute('aria-hidden', 'true');
      svg.innerHTML = '<use href="#up-right-from-square"></use>';
      
      link.appendChild(svg);
    });
  }
});
