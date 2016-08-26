![caiman](assets/img/caiman.png)

# minimal-cayman

This is a minimal [Cayman](https://github.com/jasonlong/cayman-theme) alteration, with a bit more config, and made for jekyll. It natively includes Open Graph, Twitter cards, and OS Protocol metatags. The CSS colors avoid the flashy Cayman colors in favor of something a bit more subtle.

Partly based on [jekyll-cayman-theme](https://github.com/pietromenna/jekyll-cayman-theme), too.

## Install

```sh
git clone https://github.com/RichardLitt/minimal-cayman
```

## Usage

Edit the `_config.yml` file according to your own specifications. Also edit the `index.md` to display your own content.

### Compressing images

Put any uncompressed images into `src/img`. Then, run `gulp`: this will compress them and make them better for the web, and copy them to `assets/img`.

If `gulp` doesn't work, run: `npm install`.

### favicon.ico

You'll need to replace this, and the logo, with your own images.

### Checklist for repurposing theme:

- [ ] Edit `_config.yml`.
- [ ] Edit `index.md`.
- [ ] Replace logo with your own logo.
  - [ ] Remove old logo entirely, from `src/` and `assets`.
- [ ] Replace favicon with your own favicon.
- [ ] Edit `package.json` if you plan on using semver to save and deploy website.
- [ ] Remove or edit CNAME.
- [ ] Deploy!
- [ ] Edit this README to reflect current website.

## Contribute

Please do! Check out the [issues](https://github.com/RichardLitt/minimal-cayman), or open a PR.

Note that this README follows the [Standard-Readme](https://github.com/RichardLitt/standard-readme) protocol.

## License

[MIT](LICENSE) © Richard Littauer

### Logo

Logo adapted from [Wikipedia](https://en.wikipedia.org/wiki/Caiman#/media/File:Paleosuchus_palpebrosus_Prague_2011_3.jpg), under CC-BY-SA 3.0 License
