# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require 'neo'


describe Neo::Node do
  before(:all) do
    Neo::start
  end

  after(:all) do
    Neo::stop
  end  

  it "should construct a new node in a transaction"  do
    node = nil
    Neo::transaction {
      node = Neo::Node.new
    }
    node.should be_an_instance_of Neo::Node
  end

  it "should run in a transaction if a block is given at new"  do
    node = Neo::Node.new { }
    node.should be_an_instance_of Neo::Node    
  end
  
  it "should have a constructor that takes a native Neo Java object" do
    node1 = Neo::Node.new { }
    node2 = Neo::Node.new(node1.internal_node)
    
    node1.internal_node.should be_equal(node2.internal_node)
  end
  
  
  it "should have setter and getters for any property" do
    #given
    node = Neo::Node.new do |n|
      n.foo = "foo"
      n.bar = "foobar"
    end
    
    # then
    node.foo.should == "foo"
    node.bar.should == "foobar"
  end
  

  it "should allow to declare properties"  do
    # given
    class Person < Neo::Node
      properties :name, :age 
    end
    
    # when
    person = Person.new {|node|
      node.name = "kalle"
      node.age = 42
    }
    
    # then
    person.name.should == "kalle"
    person.age.should == 42
  end

  it "should have generated setter and getters for declared properties" do
    # given
    class Person < Neo::Node
      properties :my_property
    end

    # when
    p = Person.new {}
    
    # then
    p.methods.should include("my_property")
    p.methods.should include("my_property=")
  end

  it "should have generated setter and getters for subclasses as well" do
    # given
    class Person < Neo::Node
      properties :my_property
    end

    class Employee < Person
      properties :salary
    end

    # when
    p = Employee.new {}
    
    # then
    p.methods.should include("my_property")
    p.methods.should include("my_property=")
    p.methods.should include("salary")
    p.methods.should include("salary=")
  end
  
  
  it "should allow to declare relations" do
    #given
    class Person < Neo::Node
      properties :name, :age 
      #  relations :friend # TODO
    end
    
    p1 = Person.new do|node|
       node.name = "p1"
    end

    # then    
    p2 = Person.new do|node|
       node.name = "p2"
       node.friends << p1
    end
  end


  it "should have relationship getters that returns Enumerable objects" do
    #given
    class Person < Neo::Node
      properties :name, :age 
      #  relations :friend # TODO
    end
    
    p1 = Person.new do|node|
       node.name = "p1"
    end

    p2 = Person.new do|node|
       node.name = "p2"
       node.friends << p1
    end
    
    # then
    p2.friends.should be_kind_of Enumerable
    found = p2.friends.find{|node| node.name == 'p1'}
    found.name.should == "p1"
  end
  
  
  it "should do stuff" do
    class Person < Neo::Node
      properties :name, :age 
      #  relations :friend, :child
    end
    
    class Employee < Person
      properties :salary 
      
      def to_s
        "Employee #{@name}"
      end
    end
    
    n1 = Employee.new do |node| # this code body is run in a transaction
      node.name = "kalle"
      node.salary = 10
    end 
  end
end
