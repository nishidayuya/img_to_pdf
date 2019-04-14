# image_to_pdf

A tool to create PDF from raster image.

[![License X11](https://img.shields.io/badge/license-X11-brightgreen.svg)](https://raw.githubusercontent.com/nishidayuya/image_to_pdf/master/LICENSE.txt)

## Requirements

* Ruby
* ImageMagick

## Installation

```sh
$ gem install image_to_pdf
```

## Usage

Create PDF from PNG:

```sh
$ image_to_pdf input.png output.pdf
```

Same as:

```sh
$ image_to_pdf \
    --paper-size=a4-landscape \
    --horizontal-pages=1 \
    --vertical-pages=1 \
    input.png output.pdf
```

Create 3x4 pages B5 portrait PDF from JPG:

```
$ image_to_pdf \
    --paper-size=b5-portrait \
    --horizontal-pages=3 \
    --vertical-pages=4 \
    input.jpg output.pdf
```

Show help message:

```
$ image_to_pdf --help
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nishidayuya/image_to_pdf .
