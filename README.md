# Vermont trip expenses

A shared expense tracker. Anyone with the link can join the trip, add expenses with a bill photo, split them equally or with custom amounts, and see who owes whom. No sign-in needed.

Setup takes about 15 minutes.

## 1. Create the Supabase project

1. Sign up at [supabase.com](https://supabase.com) (the free plan is enough) and create a new project. Pick any name and database password.
2. When it's ready, open **SQL Editor → New query**, paste the whole of `supabase-setup.sql`, and click **Run**. You should see "Success. No rows returned".
3. Open **Project Settings → API** (or the **Connect** button) and copy two values:
   - **Project URL**, like `https://abcdefgh.supabase.co`
   - **anon public key** (older projects) or **publishable key** (newer projects, starts with `sb_publishable_`)

   Do not use the `service_role` or secret key. It would give anyone full control of your project.

## 2. Connect the page

Open `index.html`, find these two lines near the top of the main script, and paste in your values:

```js
const SUPABASE_URL = "PASTE_YOUR_SUPABASE_URL_HERE";
const SUPABASE_KEY = "PASTE_YOUR_ANON_OR_PUBLISHABLE_KEY_HERE";
```

To test, open `index.html` in your browser. It should load "Vermont trip" with no members yet.

## 3. Publish on GitHub Pages

1. Create a new **public** repository on GitHub, for example `vermont-trip`.
2. Upload `index.html` (the README and SQL file are optional).
3. Go to **Settings → Pages**. Under **Build and deployment**, set Source to **Deploy from a branch**, branch **main**, folder **/ (root)**, then **Save**.
4. After a minute or two the site will be live at `https://<your-github-username>.github.io/vermont-trip/`. Share that link.

## Using it

- Everyone opens the link, goes to **Members**, adds themselves (or one person adds the whole group), and taps **This is me**. That's remembered on their phone or browser.
- **Add expense** for every bill. The amount is split equally among the ticked people, or switch to **Custom amounts**.
- **Balances** shows who's up and who's down, plus the fewest payments needed to settle up.
- **Members → Download expenses as CSV** exports everything, including links to the bills.

**Another trip later:** add `?trip=` to the link, for example `.../vermont-trip/?trip=nyc-december`. That trip starts empty and is created the first time someone opens it.

## Good to know

- **The link is the key.** Anyone with the link can add, edit, or delete expenses. That's fine among friends, but don't post it publicly.
- **The key in the page is visible.** The anon/publishable key appears in the page source, and with it someone technical could read or change the data directly. Bill photos are stored in a public bucket under random file names.
- **Free projects pause.** Supabase pauses free projects after about a week with no activity. If the page stops loading after the trip, open your Supabase dashboard and click **Restore**.
- **File sizes.** Photos are resized and compressed before upload. PDFs can be up to 10 MB.
