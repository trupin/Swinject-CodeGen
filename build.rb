require "erb"
require "Shellwords"
require "set"

@dependencies = Set.new
@contentArray = []
@migrationArray = []

ARGV[0..-2].each do |filename|
  f = File.open(filename)

  f.each_line {|line|
    if line.nil? || line.chomp.empty?
      # ignores empty lines
    elsif line.start_with?("#")
       # detect command
      if(line.start_with?("#ADD_DEPENDENCY "))
        @dependencies.add(line.split(" ")[1])
      elsif(line.start_with?("# ADD_DEPENDENCY "))
        @dependencies.add(line.split(" ")[2])
      end
    elsif line.start_with?("//")
        # ignores comments
    else
        # UIViewController, TelecastViewController, name, Telecast2, Telecast3
        array = line.split(";").map { |a| a.strip }
        arguments = array[3..-1]
        argumentHashes = nil
        unless arguments.nil?
            arguments.reject { |a| a.empty? }
            argumentHashes = arguments.map do |a|
                hash = nil
                if(a.include?(":"))
                    hash = {
                        :argumentName => a.split(":").first.strip,
                        :argumentType => a.split(":").last.strip
                    }
                else
                    hash = {
                        :argumentName => a.downcase,
                        :argumentType => a
                    }
                end
                hash
            end
        end

        targetClass = array[1]
        targetClassName = targetClass.gsub("<", "").gsub(">", "")
        baseClass = array[0]

        name = array[2]

        hasNoName = (name.nil? || name.empty?)

        registerFunctionSignature = "register"
        registerFunctionSignature = registerFunctionSignature + targetClassName
        registerFunctionSignature = registerFunctionSignature + "_#{name}" unless hasNoName
        registerFunctionSignature = registerFunctionSignature + "(registerClosure: (resolver: ResolverType"
        registerFunctionSignature = registerFunctionSignature + ", " unless (argumentHashes.nil? || argumentHashes.empty?)
        registerFunctionSignature = registerFunctionSignature + argumentHashes.map {|a| "#{a[:argumentName]}: #{a[:argumentType]}"}.join(", ") unless (argumentHashes.nil? || argumentHashes.empty?)
        registerFunctionSignature = registerFunctionSignature + ") -> (#{targetClass})) -> ServiceEntry<#{baseClass}>"

        registerFunctionCall = ".register("
        registerFunctionCall = registerFunctionCall + "#{baseClass}.self,"
        registerFunctionCall = registerFunctionCall + " name: \"#{name}\"," unless hasNoName

        resolveFunctionSignature = "resolve"
        resolveFunctionSignature = resolveFunctionSignature + targetClassName
        resolveFunctionSignature = resolveFunctionSignature + "_#{name}" unless hasNoName
        resolveFunctionSignature = resolveFunctionSignature + "("
        resolveFunctionSignature = resolveFunctionSignature + argumentHashes.map {|a| "#{a[:argumentName]}: #{a[:argumentType]}"}.join(", ") unless (argumentHashes.nil? || argumentHashes.empty?)
        resolveFunctionSignature = resolveFunctionSignature + ") -> #{targetClass}"

        resolveFunctionCall = ".resolve("
        resolveFunctionCall = resolveFunctionCall + "#{baseClass}.self"
        resolveFunctionCall = resolveFunctionCall + ", name: \"#{name}\"" unless hasNoName

        hash = {
            :baseClass => baseClass,
            :targetClass => targetClass,
            :targetClassName => targetClassName,
            :name => name,
            :arguments => argumentHashes,
            :resolveFunctionSignature => resolveFunctionSignature,
            :resolveFunctionCall => resolveFunctionCall,
            :registerFunctionSignature => registerFunctionSignature,
            :registerFunctionCall => registerFunctionCall,
        }
        @contentArray.push hash

        registerFunctionCallWithoutLastComma = registerFunctionCall.reverse.sub(",", "").reverse

        migrationHash = {
          :resolveFunctionSignatureRegex => Shellwords.escape(".#{resolveFunctionSignature.split("->").first.strip}"),
          :resolveFunctionCall => Shellwords.escape("#{resolveFunctionCall})!"),
          :registerFunctionSignatureRegex => Shellwords.escape(".#{registerFunctionSignature.split("(").first}"),
          :registerFunctionCall => Shellwords.escape("#{registerFunctionCallWithoutLastComma})")
        }
        @migrationArray.push migrationHash

    end
  }
end

fileToWriteTo = File.open(ARGV[-1], 'w')
fileToWriteTo.puts ERB.new(File.read('erb/template.erb'), nil, "-").result
puts "Generated code in #{ARGV[-1]}"
fileToWriteTo.close

migrationFileName = "#{ARGV[-1]}.migration.sh"

migrationFileToWriteTo = File.open(migrationFileName, 'w')
migrationFileToWriteTo.puts ERB.new(File.read('erb/migration.erb'), nil, "-").result
puts "Generated migration code in #{migrationFileName}"
migrationFileToWriteTo.close