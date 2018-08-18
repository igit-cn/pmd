# Generates a table of contents based on markdown headers in the body
#
# The block's arg may be an int describing the maximum depth at which
# headers are added to the toc

class TocMakerBlock < Liquid::Block
  # include Enumerable

  def initialize(tag_name, arg, tokens)
    super
    @max_depth = arg.to_s.empty? ? 100 : arg.to_i
    @body = tokens
  end

  def to_internal_link(header)
    url = header.downcase.gsub(/\s+/, "-")

    "[#{header}](##{url})"
  end

  def render(context)

    contents = @body.render(context)


    headers = contents.lines.map {|l|
      if /^(#+)\s+(\S.*)$/ =~ l
        [$1.length, $2]
      end
    }.compact

    min_indent = headers.min_by {|t| t[0]}[0]

    headers = headers.map {|t|
      actual_depth = t[0] - min_indent
      if actual_depth < @max_depth then

        indent = "    " * actual_depth

        "#{indent}* #{to_internal_link(t[1])}"
      end
    }.compact

    headers.unshift("### Table Of Contents\n")

    headers.join("\n") + contents
  end
end


Liquid::Template.register_tag('tocmaker', TocMakerBlock)
