import { analyticsSearch } from "./useCatalogs";

describe("analyticsSearch", () => {
  it("drops paging params and keeps the rest", () => {
    const params = new URLSearchParams("search=ada&page=2&limit=50");

    expect(analyticsSearch(params)).toBe("?search=ada");
    expect(params.get("page")).toBe("2");
  });

  it("returns an empty string when only paging params were present", () => {
    expect(analyticsSearch(new URLSearchParams("page=1&limit=20"))).toBe("");
  });

  it("preserves compensation filters", () => {
    const params = new URLSearchParams();
    params.set("filters[with_country_id]", "10");
    params.set("page", "3");

    expect(analyticsSearch(params)).toBe("?filters%5Bwith_country_id%5D=10");
  });
});
