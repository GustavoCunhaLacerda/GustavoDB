describe 'database' do
  before do
    `rm -rf ./test.db`
  end

    def run_script(commands)
      raw_output = nil
      IO.popen("./db ./test.db", "r+") do |pipe|
        commands.each do |command|
          pipe.puts command
        end
  
        pipe.close_write
  
        # Read entire output
        raw_output = pipe.gets(nil)
      end
      raw_output.split("\n")
    end
  
    it "insere e seleciona uma linha" do
      result = run_script([
        "insert 1 user1 email.user1@gmail.com",
        "select",
        ".exit",
      ])
      expect(result).to match_array([
        "g_db > Executed.",
        "g_db > (1, user1, email.user1@gmail.com)",
        "Executed.",
        "g_db > ",
      ])
    end

    it "printa um erro se a tabela estiver cheia" do
      script = (1..1401).map do |i|
        "insert #{i} user#{i} email.user#{i}@gmail.com"
      end
      script << ".exit"
      result = run_script(script)
      expect(result[-2]).to eq("g_db > Error: Table full.")
    end

    it "permite inserir strings de comprimento máximo" do
      long_username = "a"*32
      long_email = "a"*255
      script = [
        "insert 1 #{long_username} #{long_email}",
        "select",
        ".exit"
      ]
      result = run_script(script)
      expect(result).to match_array([
        "g_db > Executed.",
        "g_db > (1, #{long_username}, #{long_email})",
        "Executed.",
        "g_db > "
      ])
    end

    it "printa erro se a string for maior que o permitido" do
      long_username = "a"*33
      long_email = "a"*256
      script = [
        "insert 1 #{long_username} #{long_email}",
        "select",
        ".exit"
      ]
      result = run_script(script)
      expect(result).to match_array([
        "g_db > String is too long.",
        "g_db > Executed.",
        "g_db > "
      ])
    end

    it "printa erro se o id for negativo" do 
      script = [
        "insert -1 teste_com_ruby ruby@rspec.com",
        "select",
        ".exit"
      ]
      result = run_script(script)
      expect(result).to match_array([
        "g_db > ID must be positive.",
        "g_db > Executed.",
        "g_db > "
      ])
    end

    it "persistência de dados após o fechamento da conexão" do
      result1 = run_script([
        "insert 1 user1 email.user1@gmail.com",
        ".exit"
      ])
      expect(result1).to match_array([
        "g_db > Executed.",
        "g_db > "
      ])

      result2 = run_script([
        "select",
        ".exit"
      ])
      expect(result2).to match_array([
        "g_db > (1, user1, email.user1@gmail.com)",
        "Executed.",
        "g_db > "
      ])
    end
  end
