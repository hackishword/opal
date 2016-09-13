class ::Opal::SimpleServer
  require 'set'
  require 'erb'

  def initialize
    yield self
    freeze
  end

  attr_accessor :main, :index_path

  def append_path(path)
    Opal.append_path path
  end

  def call(env)
    case env['PATH_INFO']
    when %r{\A/assets/(.*)\z}
      call_asset($1)
    else call_index
    end
  end

  def call_asset(path)
    builder = Opal::Builder.new
    builder.build(path.gsub(/(\.(?:rb|js|opal))*\z/, ''))
    [200, {'Content-Type' => 'application/javascript'}, [builder.to_s]]
  end

  def javascript_include_tag(path)
    %{
      <script src="/assets/#{path}.js"></script>
    }
  end

  def call_index
    contents = File.read(@index_path)
    html = ERB.new(contents).result binding
    [200, {'Content-Type' => 'text/html'}, [html]]
  end
end

