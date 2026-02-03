import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("0.11.1", (api) => {
  api.decorateCooked((element) => {
    addIcons(element);
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
    if (!container || typeof container.querySelectorAll !== "function") {
      return;
    }

    // Select all links that have not yet been processed by this script.
    const links = container.querySelectorAll("a[href]:not([data-ext-icon])");
    if (!links.length) {
      return;
    }

    links.forEach((link) => {
      // Mark the link as processed immediately to prevent re-running.
      link.setAttribute("data-ext-icon", "processed");

      // --- Start of Exclusion Rules ---

      // Rule 1: Exclude links based on their context or class. These are fast, safe checks.
      if (link.closest("#topic-title") || link.matches("a.title") ||
          link.closest(".onebox, .breadcrumb") ||
          link.matches(".mention, .hashtag, [data-user-card], .back")) {
        return;
      }
      
      // Rule 2: Safely parse the link's URL. Invalid URLs (like 'mailto:') will
      // throw an error, so we catch it and skip the link.
      let linkUrl;
      try {
        linkUrl = new URL(link.href);
      } catch (e) {
        return; // Skip invalid URLs.
      }
      
      // Rule 3: Exclude links that are not http or https.
      if (!["http:", "https:"].includes(linkUrl.protocol)) {
        return;
      }
      
      // Rule 4: Exclude internal links by comparing the hostname.
      if (linkUrl.hostname === window.location.hostname) {
        return;
      }
      
      // --- End of Exclusion Rules ---

      // If a link passes all the checks, it's a true external link. Add the icon.
      const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      svg.setAttribute('class', 'fa d-icon d-icon-up-right-from-square svg-icon svg-string ext-icon');
      svg.setAttribute('aria-hidden', 'true');
      svg.innerHTML = '<use href="#up-right-from-square"></use>';
      
      link.appendChild(svg);
      
      // Overwrite the 'processed' status to 'true' to signify an icon was added.
      link.setAttribute("data-ext-icon", "true");
    });
  }
});
