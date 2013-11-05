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

    p results[0]

    User.new(results[0]) unless results.empty?
  end

  def self.find_by_name(fname, lname)
    results = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT * FROM users WHERE users.fname = ? AND users.lname = ?
    SQL

    User.new(results[0]) unless results.empty?
  end

  def initialize(options = {})
    @id, @fname, @lname =
    options.values_at("id", "fname", "lname")

    save(@fname, @lname) if @id.nil?
  end

  def save(f_name, l_name)

    # unless @id.nil?
    #   QuestionsDatabase.instance.execute(<<-SQL, f_name, l_name, @id)
    #   UPDATE
    #     users
    #   SET users.fname = ?, users.lname = ?
    #   WHERE users.id = ?
    #   SQL
    #
    # else
      QuestionsDatabase.instance.execute(<<-SQL, f_name, l_name)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
      SQL

      @id = QuestionsDatabase.instance.last_insert_row_id
    # end

  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollower.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    karma_for_each_question = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT COUNT(question_likes.question_id)
    FROM questions
    LEFT OUTER JOIN question_likes ON (questions.id = question_likes.question_id)
    WHERE questions.user_id = ?
    GROUP BY(question_id);
    SQL

    total_karma = karma_for_each_question.inject(0) { |a,i| a + i.values[0]}
    total_questions = karma_for_each_question.size
    return 0 if total_questions == 0
    average_karma = total_karma / total_questions
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

  def self.most_followed(n)
    QuestionFollower.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
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

  def followers
    QuestionFollower.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
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

  def self.followers_for_question_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT DISTINCT
      user_id, fname, lname
    FROM
      question_followers qf
    JOIN users u ON u.id = qf.user_id
    WHERE
      qf.question_id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def self.followed_questions_for_user_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT DISTINCT
      questions.id, title, body, question_followers.user_id
    FROM
      question_followers
    JOIN questions ON questions.id = question_followers.question_id
    WHERE
      question_followers.user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
        q.id, title, body, qf.user_id, COUNT(q.id)
    FROM
      question_followers qf
    JOIN questions q ON q.id = qf.question_id
    GROUP BY
      q.id
    ORDER BY
      COUNT(q.id) DESC
    LIMIT ?
    SQL

    results.map { |result| Question.new(result) }
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
    SELECT * FROM question_likes WHERE question_likes.id = ?
    SQL

    QuestionLike.new(results[0]) unless results.empty?
  end

  def self.likers_for_question_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT DISTINCT
      user_id, fname, lname
    FROM
      question_likes ql
    JOIN users u ON u.id = ql.user_id
    WHERE
      ql.question_id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def self.num_likes_for_question_id(id)
    number = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT
      COUNT(*)
    FROM
      question_likes ql
    JOIN users u ON u.id = ql.user_id
    WHERE
      ql.question_id = ?
    SQL
    number[0].values[0]
  end

  def self.liked_questions_for_user_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
    SELECT DISTINCT
      questions.id, title, body, question_likes.user_id
    FROM
      question_likes
    JOIN questions ON questions.id = question_likes.question_id
    WHERE
      question_likes.user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.most_liked_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
        q.id, title, body, ql.user_id, COUNT(q.id)
    FROM
      question_likes ql
    JOIN questions q ON q.id = ql.question_id
    GROUP BY
      q.id
    ORDER BY
      COUNT(q.id) DESC
    LIMIT ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def initialize(options = {})
    @question_id, @user_id =
    options.values_at("question_id", "user_id")
  end


end  #END CLASS QUESTIONLIKE