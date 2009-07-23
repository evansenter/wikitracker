module Assertions
  def assert_valid(model)
    assert model.valid?
  end
  
  def assert_not_valid(model)
    assert ! model.valid?
  end
  
  def assert_not_valid_on(model, attribute, message)
    assert_not_valid( model )
    assert_equal message, model.errors.on( attribute )
  end
end