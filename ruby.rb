require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
    include Singleton

    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end






class User
    attr_accessor :id, :fname, :lname
    def self.find_by_id(id)
        user = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
            *
        FROM
            users
        WHERE
            id = ?        
        SQL
        return nil unless user.length > 0

        User.new(user.first)
    end

    def self.find_by_name(fname, lname)
        user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
        SELECT 
        *
        FROM 
        users
        WHERE
        fname = ? AND lname = ?
        SQL
        return nil if user.empty?
        User.new(user.first)
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def authored_questions
        Question.find_by_author_id(@id)
    end

    def authored_replies
        Reply.find_by_user_id(@id)
    end

    def followed_questions
        QuestionFolllow.followed_questions_for_user_id(@id)
    end

    def liked_questions
        Question_like.liked_questions_for_user_id(@id)
    end
end






class Question
    attr_accessor :id, :title, :body, :author_id
    def self.find_by_id(id)
        question = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
            *
        FROM
            questions
        WHERE
            id = ?        
        SQL
        return nil unless question.length > 0

        Question.new(question.first)
    end

    def self.find_by_author_id(author_id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
        SELECT
        *
        FROM
        questions
        WHERE
        author_id = ?
        SQL
        return nil unless questions.length > 0

        questions.map {|question| Question.new(question)}
    end

    def self.most_followed(n)
        QuestionFolllow.most_followed_questions(n)
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
    end

    def author
        user = QuestionsDatabase.instance.execute(<<-SQL, @author_id)
        SELECT
            *
        FROM
            users
        WHERE
            id = ?
        SQL
        return nil unless user.length > 0

        User.new(user.first)
    end

    def replies
        Reply.find_by_question_id(@id)
    end

    def followed_questions
        QuestionFolllow.followers_for_question_id(@id)
    end

    def likers
        Question_like.likers_for_question_id(@id)
    end

    def num_likes 
        Question_like.num_likes_for_question_id(@id)
    end
end






class Question_follow
    attr_accessor :id, :user_id, :question_id
    def self.find_by_id(id)
        question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
            *
        FROM
            question_follows
        WHERE
            id = ?        
        SQL
        return nil unless question_follow.length > 0

        Question_follow.new(question_follow.first)
    end

    def initialize(options)
        @id = options['id']
        @user_id = options['user_id']
        @question_id = options['question_id']
    end

    def self.followers_for_question_id(question_id)
        followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT 
        *
        FROM users
        JOIN 
        question_follows ON users.id = question_follows.user_id
        WHERE
        question_follows.question_id = ?
        SQL
        return nil unless followers.length > 0

        followers.map{|user| User.new(user) }
    end
    
    def self.followed_questions_for_user_id(user_id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT
        *
        FROM
        question_follows
        JOIN questions ON question_follows.question_id = questions.id
        WHERE
        author_id = ?
        SQL
        return nil unless questions.length > 0

        questions.map{|question| Questions.new(question)}
    end

    def self.most_followed_questions(n)
        most_followed_questions = QuestionsDatabase.instance.execute(<<-SQL, n)
        SELECT 
        *
        FROM
        questions
        JOIN
        question_follows ON questions.id = question_follows.question_id
        GROUP BY
        question_follows.question_id
        ORDER BY
        COUNT(question_follows.user_id) DESC
        LIMIT ?
        SQL
        most_followed_questions.map{|question| Question.new(question)}
    end
end




class Reply
    attr_accessor :id, :body, :subject_question_id, :author_id, :parent_reply_id
    def self.find_by_id(id)
        reply = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
            *
        FROM
            replies
        WHERE
            id = ?        
        SQL
        return nil unless reply.length > 0

        Reply.new(reply.first)
    end

    def initialize(options)
        @id = options['id']
        @body = options['body']
        @subject_question_id = options['subject_question_id']
        @author_id = options['author_id']
        @parent_reply_id = options['parent_reply_id']
    end

    def self.find_by_user_id(user_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT 
            *
        FROM 
            replies
        WHERE 
            id = ?
        SQL
        return nil if replies.length == 0
        replies.map {|reply| Reply.new(reply)}
    end

    def self.find_by_question_id(question_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT
        *
        FROM
        replies
        WHERE
        subject_question_id = ?
        SQL

        return nil unless replies.length > 0

        replies.map {|reply| Reply.new(reply)}
    end

    def author
        user = QuestionsDatabase.instance.execute(<<-SQL, @author_id)
        SELECT
            *
        FROM
            users
        WHERE
            id = ?
        SQL
        return nil unless user.length > 0

        User.new(user.first)
    end

    def question
        question = QuestionsDatabase.instance.execute(<<-SQL, @subject_question_id)
        SELECT
            *
        FROM
            questions
        WHERE
            id = ?
        SQL
        return nil unless question.length > 0

        Question.new(question.first)
    end

    def parent_reply
        reply = QuestionsDatabase.instance.execute(<<-SQL, @parent_reply_id)
        SELECT
        *
        FROM
        replies
        WHERE
        id = ?
        SQL
        return nil unless reply.length > 0

        Reply.new(reply.first)
    end

    def child_replies
        children = QuestionsDatabase.instance.execute(<<-SQL, @id)
        SELECT 
        *
        FROM
        replies
        WHERE
        parent_reply_id = ?
        SQL
        return nil if children.empty?
        children.map{|child| Reply.new(child)}
    end
end





class Question_like
    attr_accessor :id, :question_id, :user_id
    def self.find_by_id(id)
        question_like = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
            *
        FROM
            question_likes
        WHERE
            id = ?        
        SQL
        return nil unless question_like.length > 0

        Question_like.new(question_like.first)
    end

    def self.likers_for_question_id(question_id)
        likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT
        *
        FROM 
        users

        JOIN
        question_likes ON users.id = question_likes.user_id

        WHERE
        question_likes.question_id = ?
        SQL

        likers.map{|user| User.new(user)}
    end

    def self.num_likes_for_question_id(question_id)
        likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
        SELECT
        COUNT(*)
        FROM 
        users

        JOIN
        question_likes ON users.id = question_likes.user_id

        WHERE
        question_likes.question_id = ?
        SQL

        likers.first.first
    end

    def self.liked_questions_for_user_id(user_id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
        SELECT
        *
        FROM 
        questions
        JOIN
        question_likes ON question_likes.question_id = question.id
        WHERE
        question_likes.user_id = ?
        SQL
        questions.map{ |question| Question.new(question) }
    end

    def initialize(options)
        @id = options[id]
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end