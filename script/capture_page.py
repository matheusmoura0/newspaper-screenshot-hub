import argparse
import json
import os
import time

from playwright.sync_api import TimeoutError as PlaywrightTimeoutError
from playwright.sync_api import sync_playwright


CONSENT_SELECTORS = [
    "button:has-text('Aceitar')",
    "button:has-text('Aceito')",
    "button:has-text('Concordo')",
    "button:has-text('Accept')",
    "#onetrust-accept-btn-handler",
]


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--width", type=int, required=True)
    parser.add_argument("--height", type=int, required=True)
    parser.add_argument("--scale", type=float, default=1)
    parser.add_argument("--options", default="{}")
    return parser.parse_args()


def click_first_visible(page, selectors):
    for selector in selectors:
        try:
            locator = page.locator(selector).first
            if locator.is_visible(timeout=500):
                locator.click(timeout=1500)
                return selector
        except Exception:
            continue
    return None


def warm_lazy_content(page, height):
    page.evaluate("window.scrollTo(0, 0)")
    total_height = page.evaluate("document.documentElement.scrollHeight")
    position = 0
    while position < min(total_height, 30000):
        position += height
        page.evaluate("position => window.scrollTo(0, position)", position)
        page.wait_for_timeout(180)
    page.evaluate("window.scrollTo(0, 0)")
    page.wait_for_timeout(500)


def main():
    args = parse_args()
    options = json.loads(args.options)
    started_at = time.monotonic()

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(
            headless=True,
            args=["--disable-dev-shm-usage", "--no-sandbox", "--disable-notifications"],
        )
        context = browser.new_context(
            viewport={"width": args.width, "height": args.height},
            device_scale_factor=args.scale,
            locale="pt-BR",
            timezone_id=options.get("time_zone", "America/Sao_Paulo"),
            ignore_https_errors=True,
            user_agent=options.get(
                "user_agent",
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/139 Safari/537.36",
            ),
        )
        page = context.new_page()
        page.set_default_timeout(int(options.get("timeout_ms", 30000)))
        page.goto(args.url, wait_until="domcontentloaded", timeout=int(options.get("navigation_timeout_ms", 60000)))

        try:
            page.wait_for_load_state("networkidle", timeout=int(options.get("network_idle_timeout_ms", 15000)))
        except PlaywrightTimeoutError:
            page.wait_for_timeout(2500)

        clicked = click_first_visible(page, CONSENT_SELECTORS + options.get("click_selectors", []))
        if options.get("wait_for_selector"):
            page.locator(options["wait_for_selector"]).first.wait_for(state="visible")
        for selector in options.get("hide_selectors", []):
            page.locator(selector).evaluate_all("elements => elements.forEach(element => element.style.display = 'none')")

        warm_lazy_content(page, args.height)
        page.wait_for_timeout(int(options.get("extra_delay_ms", 1000)))
        page.screenshot(path=args.output, full_page=True, animations="disabled")
        dimensions = page.evaluate("({ width: document.documentElement.scrollWidth, height: document.documentElement.scrollHeight })")
        browser.close()

    if not os.path.exists(args.output) or os.path.getsize(args.output) == 0:
        raise RuntimeError("O Playwright não gerou uma imagem válida")

    print(json.dumps({**dimensions, "consent_clicked": clicked, "elapsed_ms": round((time.monotonic() - started_at) * 1000)}))


if __name__ == "__main__":
    main()
