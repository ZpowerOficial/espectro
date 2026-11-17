#!/usr/bin/env python3
import asyncio
import os
from playwright.async_api import async_playwright

ARTIFACT_DIR = "/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2"

async def capture():
    os.makedirs(ARTIFACT_DIR, exist_ok=True)
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        
        # 1. Mobile viewport: 390x844 (iPhone 14 standard)
        context_mobile = await browser.new_context(
            viewport={"width": 390, "height": 844},
            device_scale_factor=2,
            is_mobile=True,
            has_touch=True,
        )
        page_mobile = await context_mobile.new_page()
        
        print("Loading mobile teia map...")
        await page_mobile.goto("http://localhost:8080/#/atlas?v=1&view=map", wait_until="networkidle")
        await page_mobile.wait_for_timeout(4000)
        
        shot1 = os.path.join(ARTIFACT_DIR, "teia_mobile_redesign_single.png")
        await page_mobile.screenshot(path=shot1)
        print(f"Captured: {shot1}")
        
        # Tap on '+ Teia' in the mobile strip to show multi-tab switching
        add_btn = page_mobile.locator('flt-semantics[aria-label*="Adicionar teia"], [key="add-teia-strip-btn"]')
        # Alternatively tap near the tab bar or center of the canvas to open inspector
        await page_mobile.mouse.click(195, 422)
        await page_mobile.wait_for_timeout(1500)
        
        shot2 = os.path.join(ARTIFACT_DIR, "teia_mobile_inspector_open.png")
        await page_mobile.screenshot(path=shot2)
        print(f"Captured: {shot2}")
        
        # Mobile profile screen showing realistic fluid percentages (e.g. 73%, 81%, 86% without 100%)
        print("Loading mobile profile with realism calibration...")
        await page_mobile.goto("http://localhost:8080/#/atlas?subject=current:socialismo_democratico&tab=dimensoes", wait_until="networkidle")
        await page_mobile.wait_for_timeout(3500)
        
        shot3 = os.path.join(ARTIFACT_DIR, "profile_calibrated_percentages_mobile.png")
        await page_mobile.screenshot(path=shot3)
        print(f"Captured: {shot3}")
        
        # 2. Desktop viewport: 1440x900
        context_desktop = await browser.new_context(
            viewport={"width": 1440, "height": 900},
            device_scale_factor=1,
        )
        page_desktop = await context_desktop.new_page()
        print("Loading desktop teia map...")
        await page_desktop.goto("http://localhost:8080/#/atlas?v=1&view=map", wait_until="networkidle")
        await page_desktop.wait_for_timeout(4000)
        
        shot4 = os.path.join(ARTIFACT_DIR, "teia_desktop_grid.png")
        await page_desktop.screenshot(path=shot4)
        print(f"Captured: {shot4}")
        
        await browser.close()
        print("All visual verification captures complete!")

if __name__ == "__main__":
    asyncio.run(capture())
