import { expect, test } from '@playwright/test';

test.beforeEach(() => { test.skip(process.env.RAYSTO_FINANCE_017_E2E !== 'on', 'The finance candidate is opt-in; run with its matching backend/preview feature flags.'); });

// Development-only, frozen UI fixture. This is not live AI/payment acceptance.
test('Today uses the shared financial summary and keeps its accounting basis visible', async ({ page }) => {
  await page.goto('/ops/preview?section=overview');
  const summary = page.getByRole('region', { name: 'Recorded financial position' });
  await expect(summary).toBeVisible({ timeout: 60000 });
  await expect(summary.getByText('UI preview · illustrative records')).toBeVisible();
  await expect(summary.getByText('Recorded result · incomplete or legacy basis')).toBeVisible();
  await expect(summary.getByText('Unknown', { exact: true })).toBeVisible();
  await summary.getByRole('button', { name: 'Inspect costs and decisions' }).click();
  await expect(page.getByRole('heading', { name: 'Understand the cost. Review the decision.' })).toBeVisible();
});

test('receipt evidence, unknown costs and dirty recipe guard', async ({ page }) => {
  await page.goto('/ops/preview?section=finance');
  await expect(page.getByRole('heading', { name: 'Understand the cost. Review the decision.' })).toBeVisible({ timeout: 60000 });
  await expect(page.getByText('Frozen UI fixture. No backend, model or PayPal acceptance is established by this preview.')).toBeVisible();
  await page.getByRole('button', { name: 'Inspect receipt', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Confirmed receipt evidence' })).toBeVisible();
  await expect(page.getByText('The UI preview has no private documents.')).toBeVisible();
  await page.getByRole('button', { name: 'Close evidence', exact: true }).click();
  await page.getByLabel('Inspect a dish').selectOption('172');
  await expect(page.getByText('The ingredient receipt and packaging cost need confirmation.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Calculate scenario', exact: true })).toBeDisabled();
  await page.getByLabel('Inspect a dish').selectOption('171');
  await page.getByRole('button', { name: 'Edit recipe and packaging' }).click();
  await page.getByLabel('Quantity per portion').fill('400');
  page.once('dialog', d => d.dismiss());
  await page.getByRole('button', { name: 'Cancel', exact: true }).click();
  await expect(page.getByLabel('Quantity per portion')).toHaveValue('400');
  page.once('dialog', d => d.accept());
  await page.getByRole('button', { name: 'Cancel', exact: true }).click();
  await expect(page.getByLabel('Quantity per portion')).toHaveCount(0);
  await page.screenshot({ path: 'test-results/finance/desktop.png', fullPage: true });
});

test('Studio custom widget cross-filters its related grid', async ({ page }) => {
  await page.goto('/ops/preview?section=finance');
  const studio = page.getByRole('region', { name: 'AG Studio restaurant finance' });
  await expect(studio).toBeVisible({ timeout: 60000 });
  await expect(studio.getByRole('heading', { name: 'Margin change' })).toBeVisible({ timeout: 60000 });
  await studio.getByRole('button', { name: /House lunch bowl.*UI sample/ }).click();
  await expect(studio.locator('.ag-row').filter({ hasText: 'Seasonal bowl' })).toHaveCount(0);
  await studio.getByRole('button', { name: 'Clear dish filter' }).click();
  await expect(studio.locator('.ag-row').filter({ hasText: 'Seasonal bowl' }).first()).toBeVisible();
  await page.screenshot({ path: 'test-results/finance/studio.png', fullPage: true });
});

test('narrow financial workspace keeps the decision and evidence readable', async ({ page }) => {
  await page.setViewportSize({ width: 360, height: 800 });
  await page.goto('/ops/preview?section=finance');
  await expect(page.getByRole('heading', { name: 'Understand the cost. Review the decision.' })).toBeVisible({ timeout: 60000 });
  await expect.poll(() => page.evaluate(() => document.documentElement.scrollWidth > innerWidth + 1)).toBe(false);
  await page.screenshot({ path: 'test-results/finance/narrow.png', fullPage: true });
});

test('saved comparison configures real Studio widgets and layout undo preserves the decision',async({page})=>{
  await page.goto('/ops/preview?section=finance');
  await expect(page.getByRole('heading',{name:'Compare a pricing decision',exact:true})).toBeVisible({timeout:60000});
  await page.getByText('Resume a saved comparison',{exact:true}).click();
  page.once('dialog',d=>d.accept());
  await page.getByRole('button',{name:/Revision 1 · expires/}).click();
  await expect(page.getByRole('heading',{name:/Lowest qualifying price/})).toBeVisible();
  const studio=page.getByRole('region',{name:'AG Studio restaurant finance'});
  await studio.getByRole('button',{name:'Compare beside ingredient evidence'}).click();
  await expect(studio.getByText('comparison revision 1',{exact:false})).toBeVisible();
  await expect(studio.locator('.ag-row').filter({hasText:'recommended'}).first()).toBeVisible();
  await expect(studio.getByRole('heading',{name:'Ingredient evidence',exact:true})).toBeVisible();
  await expect(studio.getByText(/350 g per portion/)).toBeVisible();
  await studio.getByRole('button',{name:'Open receipt #17',exact:true}).click();
  await expect(page.getByRole('heading',{name:'Confirmed receipt evidence',exact:true})).toBeVisible();
  await studio.screenshot({path:'test-results/finance/decision-studio.png'});
  await studio.getByRole('button',{name:'Undo layout change'}).click();
  await expect(page.getByRole('heading',{name:/Lowest qualifying price/})).toBeVisible();
  await page.screenshot({path:'test-results/finance/comparison-view.png',fullPage:true});
});
