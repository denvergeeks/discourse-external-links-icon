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
    if (!container?.querySelectorAll) {
      return;
    }

    const links = container.querySelectorAll("a[href]:not([data-ext-icon])");
    if (!links.length) {
      return;
    }

    links.forEach((link) => {
      link.setAttribute("data-ext-icon", "processed");

      // --- Start of Exclusion Rules ---

      // Rule 1: Topic titles and special contexts
      if (link.classList.contains("raw-topic-link") ||
          link.classList.contains("raw-link") ||
          link.classList.contains("title") ||
          link.closest(".fancy-title, .onebox, .breadcrumb, .quote") ||
          link.matches(".mention, .hashtag, [data-user-card], .back") ||
          link.querySelector("img")) {
        return;
      }
      
      // Rule 2: Parse URL safely
      let linkUrl;
      try {
        linkUrl = new URL(link.href);
      } catch {
        return;
      }
      
      // Rule 3 & 4: Protocol and hostname check
      if (!["http:", "https:"].includes(linkUrl.protocol) ||
          linkUrl.hostname === window.location.hostname) {
        return;
      }
      
      // --- End of Exclusion Rules ---

      // Add icon
      const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      svg.setAttribute('class', 'fa d-icon d-icon-up-right-from-square svg-icon ext-icon');
      svg.setAttribute('aria-hidden', 'true');
      svg.innerHTML = '<use href="#up-right-from-square"></use>';
      
      link.appendChild(svg);
      link.setAttribute("data-ext-icon", "true");
    });
  }
});
