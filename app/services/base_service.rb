# typed: true
class BaseService
  def initialize(*_args); end

  def log_error(exception)
    logger.error("Error: #{exception.message}")
    logger.error("Backtrace: #{exception.backtrace.join("\n")}")
  end

  def logger
    @logger ||= Rails.logger
  end
end
