import { isOnRepo } from "../src/gabber.js";

describe("isOnRepo function", () => {
  it("returns true for valid GitHub repository URLs", () => {
    const validRepoURLs = [
      "https://github.com/username/repo",
      "https://github.com/username/repo/tree/main",
      "https://github.com/username/repo/blob/master/README.md",
      "https://github.com/org-name/project-name",
      "https://github.com/username/repo?query=param#fragment",
    ];

    validRepoURLs.forEach((url) => {
      expect(isOnRepo(url)).toBe(true);
    });
  });

  it("returns false for invalid URLs", () => {
    const invalidURLs = [
      "not a url",
      "github.com/username/repo", // missing protocol
      "http://",
      "",
    ];

    invalidURLs.forEach((url) => {
      expect(isOnRepo(url)).toBe(false);
    });
  });

  it("returns false for non-GitHub URLs", () => {
    const nonGithubURLs = [
      "https://gitlab.com/username/repo",
      "https://bitbucket.org/username/repo",
      "https://github.io/username/repo",
      "https://gist.github.com/username/123456",
    ];

    nonGithubURLs.forEach((url) => {
      expect(isOnRepo(url)).toBe(false);
    });
  });

  it("returns false for GitHub URLs that are not repositories", () => {
    const nonRepoGithubURLs = [
      "https://github.com/",
      "https://github.com/about",
      "https://github.com/explore",
      "https://github.com/login",
      "https://github.com/marketplace",
      "https://github.com/issues",
      "https://github.com/pulls",
      "https://github.com/settings",
      "https://github.com/sponsors",
      "https://github.com/new",
    ];

    nonRepoGithubURLs.forEach((url) => {
      expect(isOnRepo(url)).toBe(false);
    });
  });

  it("returns false for all non-repo first paths", () => {
    const nonRepoFirstPaths = [
      "about",
      "collections",
      "copilot",
      "customer-stories",
      "dashboard",
      "enterprise",
      "events",
      "explore",
      "features",
      "issues",
      "login",
      "logout",
      "marketplace",
      "new",
      "notifications",
      "orgs",
      "pricing",
      "pulls",
      "search",
      "security",
      "settings",
      "signup",
      "sponsors",
      "team",
      "topics",
    ];

    nonRepoFirstPaths.forEach((path) => {
      expect(isOnRepo(`https://github.com/${path}`)).toBe(false);
      expect(isOnRepo(`https://github.com/${path}/something-else`)).toBe(false);
    });
  });

  it("handles edge cases correctly", () => {
    // Repo names that match non-repo paths but are valid repos
    expect(isOnRepo("https://github.com/username/about")).toBe(true);
    expect(isOnRepo("https://github.com/username/settings")).toBe(true);

    // Path with exactly 2 segments
    expect(isOnRepo("https://github.com/username/repo")).toBe(true);

    // Path with fewer than 2 segments
    expect(isOnRepo("https://github.com/username")).toBe(false);
    expect(isOnRepo("https://github.com/")).toBe(false);
  });
});
