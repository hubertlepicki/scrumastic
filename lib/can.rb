class Can
  def self.method_missing id, *args
    authorised = false
    user = args[0]
    model = args[1]

    if model.respond_to? "can_#{id}"
      authorised = model.send "can_#{id}", user
    end

    if block_given?
      raise PermissionDenied unless authorised
      return yield
    end

    return authorised
  end
end