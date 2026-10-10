# friendshipmania.homilabs.org

Plain HTML + one stylesheet, same approach as homilabs.org (no build step).
Pages: `index.html`, `privacy.html`, `terms.html`, `delete-account.html`.
These URLs are the ones used inside the app (`lib/config.dart`) and in the Play Console listing.

## Deploy (Hostinger hPanel — needs your login)
1. hPanel → **Websites → homilabs.org → Subdomains → Create**: name `friendshipmania`
   (document root e.g. `public_html/friendshipmania`). Hostinger adds the DNS record itself
   because homilabs.org uses Hostinger's nameservers.
2. **File Manager** → open that subdomain's folder → upload the **contents** of
   `friendshipmania-site.zip` (including the hidden `.htaccess`) and extract.
3. Wait for the free SSL certificate on the subdomain to turn green (can take a few minutes).
4. **Performance → CDN → Flush cache** (pages are cached for up to 7 days).
5. Open these four in a browser and confirm they load over https:
   `/`, `/privacy.html`, `/terms.html`, `/delete-account.html`.

## When the Play listing goes live
- Replace the Google Play button note in `index.html` and re-upload.
- Add the app to the studio site's "Live apps" list (see homilabs_site/README.md).
- Refresh `img/` if the app icon changes (`icon-144.png`, `feature.png`).

## Updating the policy
Change the "Last updated" date on any page you edit, and update the privacy page
**before** releasing an app version that collects anything new.
