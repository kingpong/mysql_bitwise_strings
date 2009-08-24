#!/usr/bin/ruby -w
require "mysql"
require "test/unit"

$user = nil
$pass = nil
while !ARGV.empty?
  case ARGV.shift
  when '-u'
    $user = ARGV.shift
  when '-p'
    $pass = ARGV.shift
  else
    raise "unrecognized argument '#{opt}'"
  end
end

module MysqlTest

  def setup
    @dbh = Mysql.real_connect("localhost", $user, $pass, "mysql")
    @ops = { :& => "str_and", :| => "str_or", :^ => "str_xor", :~ => "str_not" }
  end

  def teardown
    @dbh.close if @dbh
  end

  private
  def quote(val)
    return 'NULL' if val.nil?
    return "'#{@dbh.quote(val)}'"
  end

  def execute(sql,*args)
    sql = sql.gsub(/\?/) { quote(args.shift) }
    #puts sql
    @dbh.query(sql)
  end

  def assert_binop_equal(op,l,r,expected)
    sql = "select #{@ops[op]}(?,?)"
    result = execute(sql,l,r).fetch_row[0]
    assert_equal result, expected
  end

  def assert_unop_equal(op,l,expected)
    sql = "select #{@ops[op]}(?)"
    result = execute(sql,l).fetch_row[0]
    assert_equal result, expected
  end

end

class AndTest < Test::Unit::TestCase
  include MysqlTest

  def test_empty
    assert_binop_equal :&, "", "", ""
  end

  def test_single
    assert_binop_equal :&, "0", "1", "0"
    assert_binop_equal :&, "a", "A", "A"
  end

  def test_multiple
    assert_binop_equal :&, "01", "10", "00"
    assert_binop_equal :&, "aB", "Ab", "AB"
  end

  def test_overflow
    assert_binop_equal :&, "111", "00", "00"
    assert_binop_equal :&, "00", "111", "00"
  end

  def test_truth_table
    assert_binop_equal :&, "0", "0", "0"
    assert_binop_equal :&, "0", "1", "0"
    assert_binop_equal :&, "1", "0", "0"
    assert_binop_equal :&, "1", "1", "1"
  end

  def test_perldoc
    assert_binop_equal :&, "japh\nJunk", "_____", "JAPH\n"
  end
end

class OrTest < Test::Unit::TestCase
  include MysqlTest

  def test_empty
    assert_binop_equal :|, "", "", ""
  end

  def test_single
    assert_binop_equal :|, "0", "1", "1"
    assert_binop_equal :|, "a", "A", "a"
  end

  def test_multiple
    assert_binop_equal :|, "01", "10", "11"
    assert_binop_equal :|, "aB", "Ab", "ab"
  end

  def test_overflow
    assert_binop_equal :|, "111", "00", "111"
    assert_binop_equal :|, "00", "111", "111"
  end

  def test_truth_table
    assert_binop_equal :|, "0", "0", "0"
    assert_binop_equal :|, "0", "1", "1"
    assert_binop_equal :|, "1", "0", "1"
    assert_binop_equal :|, "1", "1", "1"
  end

  # superficial test for perl equivalency
  def test_perldoc
    assert_binop_equal :|, "JA", "  ph\n", "japh\n"
  end
end

class XorTest < Test::Unit::TestCase
  include MysqlTest

  def test_empty
    assert_binop_equal :^, "", "", ""
  end

  def test_single
    assert_binop_equal :^, "0", "1", "\001"
    assert_binop_equal :^, "a", "A", " "
  end

  def test_multiple
    assert_binop_equal :^, "01", "10", "\001\001"
    assert_binop_equal :^, "aB", "Ab", "  "
  end

  def test_reversible
    orig = "abc"
    mask = "def"
    res = execute("select str_xor(str_xor(?,?),?)", orig, mask, mask).fetch_row[0]
    assert_equal res, orig
  end

  def test_overflow
    assert_binop_equal :^, "111", "00",  "\001\0011"
    assert_binop_equal :^, "00" , "111", "\001\0011"
  end

  def test_perldoc
    assert_binop_equal :^, "j p \n", " a h", "JAPH\n"
  end

end

class NotTest < Test::Unit::TestCase
  include MysqlTest

  def test_empty
    assert_unop_equal :~, "", ""
  end

  def test_single
    assert_unop_equal :~, "1", "\316"
    assert_unop_equal :~, "a", "\236"
  end

  def test_multiple
    assert_unop_equal :~, "01", "\317\316"
    assert_unop_equal :~, "aB", "\236\275"
  end

  def test_perldoc
    assert_unop_equal :~, "japh", "\225\236\217\227"
  end

end

class PerlEquivalenceTest < Test::Unit::TestCase
  include MysqlTest

  GENERATOR = File.join(File.dirname(__FILE__),"testcases.pl")

  def test_perl_equivalence
    return unless perl = find_perl
    pipe_reader(perl, GENERATOR) do |pipe|
      while op = read_string(pipe)
        case op
        when "|"
          result, left, right = read_strings(pipe,3)
          assert_binop_equal :|, left, right, result
        when "^"
          result, left, right = read_strings(pipe,3)
          assert_binop_equal :^, left, right, result
        when "&"
          result, left, right = read_strings(pipe,3)
          assert_binop_equal :&, left, right, result
        when "~"
          result, operand = read_strings(pipe,2)
          assert_unop_equal :~, operand, result
        end
      end
    end
  end

  private

  def find_perl
    ENV["PATH"].split(':').
      map  {|path| File.join(path,"perl") }.
      find {|perl| File.executable?(perl) }
  end

  # Runs a command and yields an IO object opened for reading from the command.
  # Does *NOT* do any shell expansion (that's the point).
  # +args+ should be [program,arg1,...]
  def pipe_reader(*args)
    # avoid shell expansion using fork/exec
    reader, writer = IO.pipe
    pid = fork
    if pid
      writer.close
      yield(reader)
      Process.waitpid(pid)
    else
      begin
        reader.close
        STDIN.reopen("/dev/null")
        STDOUT.reopen(writer)
        exec(*args)
      rescue => e
        # prevent child from jumping out of this scope and continuing main program
        STDERR.puts(e.to_s)
      end
      exit! # will only reach here if exec() failed
    end
  end

  def read_string(io)
    length = io.read(4).unpack("N").first
    io.read(length)
  rescue => e
    io.eof? ? nil : raise(e)
  end

  def read_strings(io,n)
    ret = []
    n.times { ret << read_string(io) }
    ret
  end

end
