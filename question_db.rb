require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  # Ruby provides a `Singleton` module that will only let one
  # `SchoolDatabase` object get instantiated. This is useful, because
  # there should only be a single connection to the database; there
  # shouldn't be multiple simultaneous connections. A call to
  # `SchoolDatabase::new` will result in an error. To get access to the
  # *single* SchoolDatabase instance, we call `#instance`.
  #
  # Don't worry too much about `Singleton`; it has nothing
  # intrinsically to do with SQL.
  include Singleton

  def initialize
    # Tell the SQLite3::Database the db file to read/write.
    super("school_survey.db")

    # Typically each row is returned as an array of values; it's more
    # convenient for us if we receive hashes indexed by column name.
    self.results_as_hash = true

    # Typically all the data is returned as strings and not parsed
    # into the appropriate type.
    self.type_translation = true
  end
end

class User

  attr_reader :id, :fname, :lname

  def self.find_by_id(id)
    # execute a SELECT; result in an `Array` of `Hash`es, each
    # represents a single row.
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT * FROM users WHERE users.id = ?
    SQL

    User.new(results[0]) unless results.empty?
  end

  def self.find_by_name(fname, lname)
    results = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT * FROM users WHERE users.fname = ? AND users.lname = ?
    SQL

    User.new(results[0]) unless results.empty?
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def initialize(options = {})
    @id, @fname, @lname =
    options.values_at("id", "fname", "lname")
  end

end  #END CLASS USER


class Question

  attr_reader :id, :title, :body, :user_id

  def self.find_by_id(id) #q_ID
    # execute a SELECT; result in an `Array` of `Hash`es, each
    # represents a single row.
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT * FROM questions WHERE questions.id = ?
    SQL

    Question.new(results[0]) unless results.empty?
  end

  def self.find_by_author_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT * FROM questions WHERE questions.user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def initialize(options = {})
    @id, @title, @body, @user_id =
    options.values_at("id", "title", "body", "user_id")
  end

  def author
    User.find_by_id(@user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

end  #END CLASS QUESTION


class Reply

  attr_reader :id, :body, :parent_reply, :question_id, :user_id

  def self.find_by_id(id)
    # execute a SELECT; result in an `Array` of `Hash`es, each
    # represents a single row.
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT * FROM replies WHERE replies.id = ?
    SQL

    Reply.new(results[0]) unless results.empty?
  end

  def self.find_by_user_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT * FROM replies WHERE replies.user_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def self.find_by_question_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT * FROM replies WHERE replies.question_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def self.find_by_parent_reply_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT * FROM replies WHERE replies.parent_reply = ?
    SQL

    results.map { |result| Reply.new(result) }
  end


  def initialize(options = {})
    @id, @body, @parent_reply, @question_id, @user_id =
    options.values_at("id", "body", "parent_reply", "question_id", "user_id")
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Question.find_by_id(question_id)
  end

  def parent_reply
    # self is an object of class Reply
    # We want to return the reply whose reply_id is
    # the same as the current object's parent_reply
    Reply.find_by_id(@parent_reply)
  end

  def child_reply
    Reply.find_by_parent_reply_id(id)
  end

end  #END CLASS REPLY

class QuestionFollower

  attr_reader :question_id, :user_id

  def self.find_by_id(id)
    # execute a SELECT; result in an `Array` of `Hash`es, each
    # represents a single row.
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT * FROM question_followers WHERE question_followers.id = ?
    SQL

    QuestionFollower.new(results[0]) unless results.empty?
  end

  def initialize(options = {})
    @question_id, @user_id =
    options.values_at("question_id", "user_id")
  end

end  #END CLASS QUESTIONFOLLOWER



class QuestionLike

  attr_reader :question_id, :user_id

  def self.find_by_id(id)
    # execute a SELECT; result in an `Array` of `Hash`es, each
    # represents a single row.
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT * FROM question_followers WHERE question_likes.id = ?
    SQL

    QuestionLike.new(results[0]) unless results.empty?
  end

  def initialize(options = {})
    @question_id, @user_id =
    options.values_at("question_id", "user_id")
  end

end  #END CLASS QUESTIONLIKE