---
title: Why you should not catch Throwable in the business logic
description: As much as it does not make sense to catch Throwable in the business logic of your application, there are some use cases for infrastructure layer.
keywords: php,throwable,exception handler,error handling
date: 2018-10-16
permalink: "/blog/do_not_catch_throwable_in_the_business_logic.html"
---

PHP7 converted many fatal and recoverable fatal errors and warnings into a new throwable class called Error. Therefore the Throwable interface was needed to have a reference type for all throwables. The new interface called `Throwable` which is the base interface for any object that can be thrown via a throw statement.

Similar to the throwable notion in Java, both `Exception` and `Error` classes are a subtype of the `Throwable` interface. While unlike PHP, in Java Throwable is a class which caused a few issues that are known as bad practice these days. For instance, in Java, you can extend throwable or even throw it directly.

On the other hand, PHP decided to prevent that issue by making Throwable an interface. Interestingly, they also made it [impossible to implement the Throwable interface directly](https://github.com/php/php-src/blob/9003d8a4cfe810b9222273a36b9be89dda94a35b/Zend/zend_exceptions.c#L49). Which means you have to extend `Error`, or `Exception` class to create a custom exception. That way, you have all the benefits of having the Throwable interface without dealing with all bad possible use cases.

While it has been a long time that we have this new interface and despite some articles trying to help developers to understand what this change means at release time, some developers are still abusing Throwable interface by catching it in their business logic.

With some exceptions, We never want to catch `\Throwable` in our business logic. Because it covers Error subclasses including `TypeError` (When the argument or return type doesn't match), `CompileError` and `ParseError` (Syntax errors. When can't parse/eval the code) which are not something that you want to ignore in your business logic.

When it comes to business logic, The best practice is to be more specific with what type of exceptions you want to catch because must of the times you are not going to handle them in the same way, that way it makes your code easier to follow for the reader and leaves fewer surprises for refactoring it in the future.

Usually, it is a bad sign, but in some cases, you may want to catch all exceptions. For instance, you only have one exception path. Another case is when you are designing a multi-layered architecture, and all you care is to provide a custom error message for the subsequent layer. However, don't forget that in all these cases what you need is catching Exception and not Throwable simply because it also covers Error.

> Note: In PHP 7.1 and later, a catch block may specify multiple exceptions using the pipe (|) character. This is useful for when different exceptions from different class hierarchies are handled the same.

```php
try {
    // some code
} catch (FirstException | SecondException $e) {
    // handle first and second exceptions
} finally {
    // executed after the try and catch blocks
}
```

The current hierarchy looks like below:

```yaml
Throwable
    Error
        ArithmeticError
            DivisionByZeroError
        AssertionError
        CompileError
            ParseError
        TypeError
            ArgumentCountError
    Exception
        ClosedGeneratorException
        DOMException
        ErrorException
        JsonException
        LogicException
            BadFunctionCallException
                BadMethodCallException
            DomainException
            InvalidArgumentException
            LengthException
            OutOfRangeException
        PharException
        ReflectionException
        RuntimeException
            OutOfBoundsException
            OverflowException
            PDOException
            RangeException
            UnderflowException
            UnexpectedValueException
        SodiumException
```

## When do we use Throwable

### Exception handlers

The first use case is obviously for exception handlers. A PHP7+ exception handler must have the following signature `void handler( Throwable $exception )` otherwise when a subclass of Error is thrown, a PHP Fatal error will be issued with an "Uncaught Error ..." message. (Unless that is what you want.) Keep in mind that you also have the option to remove the type `void handler( $exception )` which is typical for PHP5+ exception handlers.

### Custom exception interfaces

The second place where you must use it is when you are defining an interface for your custom exception classes. If you are going to create an interface for a custom exception, make sure you extend the Throwable interface.

## When do we catch Throwable

You can catch `Throwable` when both `Error` and `Exception` are handled the same, and you are writing a framework, logging or debugging or profiling library, or anything that parses or evaluates the PHP code.

Another use case would be writing a fail-safe code where reliability is essential. However, in this case, most of the time what you want is to rethrow the exception. I'll show you an example of it later.

So, as much as it doesn't make sense to catch Throwable in the business logic of your application, there are some use cases for infrastructure layer.

### Examples

We can review a few open source packages and see what they are doing with the Throwable interface to have a better understanding of these valid use cases.

#### Custom exception interface:

Most of the Symfony components are defining their `ExceptionInterface`, and these interfaces are extending `Throwable` as they should do. As I mentioned earlier, that is one of the places where you have to use Throwable to comply with the language typing discipline and avoid runtime errors.

```php
interface ExceptionInterface extends \Throwable
{
}
```
[<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-code"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg> Source](https://github.com/symfony/security/blob/f713eea2db349c47ac821e0cb67fbd6128fd9851/Core/Exception/ExceptionInterface.php#L19)

#### Handling errors (ex. For logging purpose):

Another place where Symfony is using Throwable is the `LoggingMiddleware`. This middleware is catching the Throwable, and re-throwing it after logging it. That is an excellent example of seeing how you might catch Throwable for the sake of providing a custom log/metric/event. In this case, you have to rethrow the exception immediately.

```php
try {
    $result = $next($message);
} catch (\Throwable $e) {
    $this->logger->warning('An exception occurred while handling message {class}', array_merge(
        $this->createContext($message),
        array('exception' => $e)
    ));
    throw $e;
}
```

[<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-code"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg> Source](https://github.com/symfony/symfony/blob/2b9c142f07b7dbc11d4d392b77629fa91a5dcb41/src/Symfony/Component/Messenger/Middleware/LoggingMiddleware.php#L37)

#### Fail-safe component:

The Symfony Messenger is an excellent example of a legit use case to catch Throwable.
The AmqpReceiver can re-queue the message when it catches uncaught
throwable from a handler. So a user using this client won't miss any message even when a user made a boo-boo in his handler code.

```php
try {
    $handler($this->serializer->decode(array(
        'body' => $AMQPEnvelope->getBody(),
        'headers' => $AMQPEnvelope->getHeaders(),
    )));
    $this->connection->ack($AMQPEnvelope);
} catch (RejectMessageExceptionInterface $e) {
    $this->connection->reject($AMQPEnvelope);
    throw $e;
} catch (\Throwable $e) {
    $this->connection->nack($AMQPEnvelope, AMQP_REQUEUE);
    throw $e;
} finally {
    if (\function_exists('pcntl_signal_dispatch')) {
        pcntl_signal_dispatch();
    }
}
```
[<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-code"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg> Source](https://github.com/symfony/symfony/blob/766a82bddf8f70f10840393bc348937f3532a7a5/src/Symfony/Component/Messenger/Transport/AmqpExt/AmqpReceiver.php#L65)

As you can see, Symfony is rethrowing the exception immediately after re-queuing the message.

#### Custom errors

I also found another case where Symfony does catch Throwable.

The ConsoleApplication catches Throwable and converts it into Symfony `FatalThrowableError` which is essentially the same, and it is there just for the sake of Symfony internal error handling and also for the debug component.

```php
try {
    $bundle->registerCommands($this);
} catch (\Exception $e) {
    $this->registrationErrors[] = $e;
} catch (\Throwable $e) {
    $this->registrationErrors[] = new FatalThrowableError($e);
}
```
[<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-code"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg> Source](https://github.com/symfony/symfony/blob/64727c182205800a734f046dac8688f1ed6dea3e/src/Symfony/Bundle/FrameworkBundle/Console/Application.php#L179)

Since Laravel is using Symfony HttpKernel and Debug components, they are also transforming Throwable into Symfony `FatalThrowableError`.

Other than that, Laravel is very careful about Throwable. I found a few places where they use it for type hinting.

Slim framework only catches Throwable in its request handler. All it does is passing it to the registered error handler which again is a valid use case.

```php
try {
    $response = $this->callMiddlewareStack($request, $response);
} catch (Exception $e) {
    $response = $this->handleException($e, $request, $response);
} catch (Throwable $e) {
    $response = $this->handlePhpError($e, $request, $response);
}
```
[<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-code"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg> Source](https://github.com/slimphp/Slim/blob/6d347477d09ab7910e625cee74c8108b7b85c7f9/Slim/App.php#L409)

### More examples from packages

Symfony also uses Throwable in a few places just as a workaround to avoid include warnings.

I assume it is just a performance hack. They could do a few checks for file path and permission to make sure you can include the file. While doing it in framework level might be reasonable (assuming there is huge performance gain here). Please don't use this trick for silencing errors in your ever-changing application layer.

```php
try {
    $oldContainer = include $cache->getPath();
} catch (\Throwable $e) {
} catch (\Exception $e) {
} finally {
    error_reporting($errorLevel);
}
```
[<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-code"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg> Source](https://github.com/symfony/symfony/blob/6b8e6ce73aaec628656750c5e7370eba9c4c7756/src/Symfony/Component/HttpKernel/Kernel.php#L523)

One interesting use case is the Laravel View component. The render method is catching Throwable and flushing the state before re-throwing it.

Clearly, it is a very likely scenario for a template component to receive an Error on render step and that is a reasonable use case. Don't forget that the code is still re-throwing the exception/error.

But the code is also catching Exception here which seems unnecessary because they are making the same call to the flush method. Well, that is just a trick to keep this code PHP5+ compatible because the Throwable interface doesn't exist before PHP7. Perhaps they are going to remove it since the current version of Laravel doesn't support PHP5 anymore.

```php
try {
    $contents = $this->renderContents();
    $response = isset($callback) ? call_user_func($callback, $this, $contents) : null;
    $this->factory->flushStateIfDoneRendering();
    return ! is_null($response) ? $response : $contents;
} catch (Exception $e) {
    $this->factory->flushState();
    throw $e;
} catch (Throwable $e) {
    $this->factory->flushState();
    throw $e;
}
```
[<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-code"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg> Source](https://github.com/laravel/framework/blob/9f313ce9bb5ad49a06ae78d33fbdd1c92a0e21f6/src/Illuminate/View/View.php#L104)

Here is another place where Laravel is catching Throwable. And it is a good example to demonstrate why it is a bad idea to catch Throwable in your code.

This time it just looks like a hack to avoid TypeError. This way the code can handle Exception in case of supplying invalid or unrecognized timezone and possible TypeError since this parameter is dynamically typed and there is no null safe operator here to prevent passing null value. Perhaps we can call it lazy writing since they could do a simple type check here.

The point is that it is hard for the reader to understand the intention of the original author. Please don't use similar hacks on your application logic if you are not the only developer working on the code. In this case, it was one call to an internal PHP method, in your case you might have a call to an ever-changing domain level code.

```php
try {
    new DateTimeZone($value);
} catch (Exception $e) {
    return false;
} catch (Throwable $e) {
    return false;
}
```
[<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-code"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg> Source](https://github.com/laravel/framework/blob/ac745730492ef23a04ce614228d11e496feb625d/src/Illuminate/Validation/Concerns/ValidatesAttributes.php#L1502)

## Conclusion

You should not catch `Throwable` in the business logic of your application. It is the responsibility of the infrastructure layer to deal with `Error`.
