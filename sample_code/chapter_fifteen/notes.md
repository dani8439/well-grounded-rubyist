# *Callbacks, hooks, and runtime introspection* #

## *Callbacks and hooks* ##

### *Intercepting unrecognized messages with method_missing* ### 

#### DELEGATING WITH METHOD_MISSING ####

**Ruby's method-delegating techniques** 

#### THE ORIGINAL: BASICOBJECT#METHOD_MISSING ####

#### METHOD_MISSING, RESPOND_TO?, AND RESPOND_TO_MISSING? #### 

### *Trapping include and prepend operations* ### 

### *Intercepting extend* ###

#### SINGLETON-CLASS BEHAVIOR WITH EXTENDED AND INCLUDED ####

### *Intercepting inheritance with Class#inherited* ###

**The limits of the `inherited` callback**

### *The Module#const_missing method* ###

### *The method_added and singleton_method_added methods* ###

## *Intercepting object capability queries* ##

### *Listing an object's non-private methods* ### 

### *Listing private and protected methods* ###

### *Getting class and module instance methods* ###

#### GETTING ALL THE ENUMERABLE OVERRIDES ####

### *Listing objects' singleton methods* ###

## *Introspection of variables and constants* ## 

### *Listing local and global variables* ###

### *Listing instance variables* ###

**The irb underscore variable** 

## *Tracing execution* ##

### *Examining the stack trace with caller* ###

### *Writing a tool for parsing stack traces* ###

#### THE CALLERTOOLS::CALL CLASS ####

#### THE CALLERTOOLS::STACK CLASS ####

#### USING THE CALLERTOOLS MODULE ####

## *Callbacks and method inspection in practice* ##

### *MicroTest background: MiniTest* ###

### *Specifying and implementing MicroTest* ### 

**Note** 

## *Summary* ##
