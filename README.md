# img_to_pdf

A tool to create PDF from raster image.

[![License X11](https://img.shields.io/badge/license-X11-brightgreen.svg)](https://raw.githubusercontent.com/nishidayuya/img_to_pdf/master/LICENSE.txt)
[![Gem Version](https://badge.fury.io/rb/img_to_pdf.svg)](https://rubygems.org/gems/img_to_pdf)
[![ubuntu](https://img.shields.io/github/workflow/status/nishidayuya/img_to_pdf/ubuntu/master)](https://github.com/nishidayuya/img_to_pdf/actions?query=workflow%3Aubuntu)
[![Maintainability](https://img.shields.io/codeclimate/maintainability/nishidayuya/img_to_pdf)](https://codeclimate.com/github/nishidayuya/img_to_pdf/maintainability)

## Requirements

* Ruby
* ImageMagick

## Installation

```sh
$ gem install img_to_pdf
```

## Usage

Create PDF from PNG:

```sh
$ img_to_pdf input.png output.pdf
```

Same as:

```sh
$ img_to_pdf \
    --paper-size=a4-landscape \
    --horizontal-pages=1 \
    --vertical-pages=1 \
    input.png output.pdf
```

Create 3x4 pages B5 portrait PDF from JPG:

```
$ img_to_pdf \
    --paper-size=b5-portrait \
    --horizontal-pages=3 \
    --vertical-pages=4 \
    input.jpg output.pdf
```

Show help message:

```
$ img_to_pdf --help
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nishidayuya/img_to_pdf .
