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

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
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

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
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

    def initialize(options)
        @id = options[id]
        @question_id = options['question_id']
        @user_id = options['user_id']
    end
end