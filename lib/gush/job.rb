module Gush
  class Job
    RECURSION_LIMIT = 1000

    DEFAULTS = {
      finished: false,
      enqueued: false,
      failed: false
    }

    attr_accessor :finished, :enqueued, :failed, :workflow_id, :incoming, :outgoing,
      :finished_at, :failed_at, :started_at

    attr_reader :name

    def initialize(workflow, opts = {})
      @workflow = workflow
      options = DEFAULTS.dup.merge(opts)
      assign_variables(options)
    end

    def as_json
      {
        name: @name,
        klass: self.class.to_s,
        finished: finished?,
        enqueued: enqueued?,
        failed: failed?,
        incoming: @incoming,
        outgoing: @outgoing,
        finished_at: @finished_at,
        started_at: @started_at,
        failed_at: @failed_at,
        running: running?
      }
    end

    def to_json(options = {})
      Gush::JSON.encode(as_json)
    end

    def self.from_hash(flow, hash)
      hash[:klass].constantize.new(flow, hash)
    end

    def work
    end

    def start!
      @enqueued = false
      @started_at = Time.now.to_i
    end

    def enqueue!
      @enqueued = true
      @failed = false
      @started_at = nil
      @finished_at = nil
      @failed_at = nil
    end

    def finish!
      @finished = true
      @enqueued = false
      @failed = false
      @finished_at = Time.now.to_i
    end

    def fail!
      @finished = true
      @failed = true
      @enqueued = false
      @finished_at = Time.now.to_i
      @failed_at = Time.now.to_i
    end

    def enqueued?
      !!enqueued
    end

    def finished?
      !!finished
    end

    def failed?
      !!failed
    end

    def succeeded?
      finished? && !failed?
    end

    def running?
      !!started_at && !finished?
    end

    def ready_to_start?
      !running? && !enqueued? && !finished? && !failed?
    end

    def has_no_dependencies?
      incoming.empty?
    end

    private

    def assign_variables(options)
      @name        = options[:name]
      @finished    = options[:finished]
      @enqueued    = options[:enqueued]
      @failed      = options[:failed]
      @incoming    = options[:incoming] || []
      @outgoing    = options[:outgoing] || []
      @failed_at   = options[:failed_at]
      @finished_at = options[:finished_at]
      @started_at  = options[:started_at]
    end
  end
end
