module EnvReader
  def EnvReader.read()
    return Hash[*File.readlines(".env", chomp: true).map { |x| x.split("=") }.flatten]
  end
end
