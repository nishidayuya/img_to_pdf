require "pathname"

# Namespace module
module ImgToPdf
  autoload(:VERSION, "img_to_pdf/version")

  # set autoload
  lib_path = Pathname(__dir__)
  Pathname.glob(lib_path / "img_to_pdf/*.rb").sort.each do |path|
    no_ext_path = path.relative_path_from(lib_path).sub_ext("")
    class_name = no_ext_path.basename.to_s.
                   split("_").map(&:capitalize).join.to_sym
    next if class_name == :Version

    autoload(class_name, no_ext_path.to_s)
  end
end
