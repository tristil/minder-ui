module Observable(T)
  getter observers

  def add_observer(observer)
    @observers ||= [] of T
    @observers.not_nil! << observer
  end

  def delete_observer(observer)
    @observers.try &.delete(observer)
  end

  def notify_observers(event_name, data = nil)
    @observers.try &.each &.update(event_name, data)
  end
end
