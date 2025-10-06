package _sysutils.impl;


import java.util.Collection;
import java.util.Comparator;
import java.util.Map;
import java.util.function.BiConsumer;
import java.util.function.BiFunction;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.function.Supplier;
import java.util.function.ToIntFunction;
import java.util.stream.Collectors;

/**
 * See <a href="https://stackoverflow.com/a/27644392/447503">How can I throw CHECKED exceptions from
 * inside Java 8 streams?</a>
 */
public final class LambdaUtil {

    private LambdaUtil() {}

    @FunctionalInterface
    public interface ConsumerWithExceptions<T, E extends Exception> {

        void accept(T t) throws E;
    }

    @FunctionalInterface
    public interface BiConsumerWithExceptions<T, U, E extends Exception> {

        void accept(T t, U u) throws E;
    }

    @FunctionalInterface
    public interface PredicateWithExceptions<T, E extends Exception> {

        boolean test(T t) throws E;
    }

    @FunctionalInterface
    public interface FunctionWithExceptions<T, R, E extends Exception> {

        R apply(T t) throws E;
    }

    @FunctionalInterface
    public interface BiFunctionWithExceptions<T, U, R, E extends Exception> {

        R apply(T t, U u) throws E;
    }

    @FunctionalInterface
    public interface SupplierWithExceptions<T, E extends Exception> {

        T get() throws E;
    }

    @FunctionalInterface
    public interface RunnableWithExceptions<E extends Exception> {

        void run() throws E;
    }

    /**
     * {@code .forEach(rethrowConsumer(name -> System.out.println(Class.forName(name))));} or
     * {@code .forEach(rethrowConsumer(ClassNameUtil::println));}
     *
     * @param <T> the type of the consumer argument
     * @param <E> the type of the exception
     * @param consumer the consumer
     * @return a sneaky-throwing Consumer
     * @throws E not really throws, but helps maintain checked exception safety
     */
    public static <T, E extends Exception> Consumer<T> rethrowConsumer(
            final ConsumerWithExceptions<T, E> consumer) throws E {
        return t -> {
            try {
                consumer.accept(t);
            } catch (final Exception exception) {
                throw throwAsUnchecked(exception);
            }
        };
    }

    // maybe it's a better alternative because exception not re-thrown
    @SuppressWarnings("unchecked")
    public static <T, E extends Exception> Consumer<T> rethrowConsumer2(
            final ConsumerWithExceptions<T, E> consumer) throws E {
        return ((ConsumerWithExceptions<T, RuntimeException>) consumer)::accept;
    }

    @SuppressWarnings("unchecked")
    public static <T, U, E extends Exception> BiConsumer<T, U> rethrowBiConsumer2(
            final BiConsumerWithExceptions<T, U, E> consumer) throws E {
        return ((BiConsumerWithExceptions<T, U, RuntimeException>) consumer)::accept;
    }

    public static <T, U, E extends Exception> BiConsumer<T, U> rethrowBiConsumer(
            final BiConsumerWithExceptions<T, U, E> biConsumer) throws E {
        return (t, u) -> {
            try {
                biConsumer.accept(t, u);
            } catch (final Exception exception) {
                throw throwAsUnchecked(exception);
            }
        };
    }

    @SuppressWarnings("unchecked")
    public static <T, E extends Exception> Predicate<T> rethrowPredicate2(
            final PredicateWithExceptions<T, E> predicate) throws E {
        return ((PredicateWithExceptions<T, RuntimeException>) predicate)::test;
    }

    /**
     * ex:
     * {@code .map(rethrowFunction(name -> Class.forName(name))) or .map(rethrowFunction(Class::forName))}
     *
     * @param <T> the type of the function argument
     * @param <R> the type of results supplied by this function
     * @param <E> the type of the exception
     * @param function the function argument
     * @return a sneaky-throwing Function
     * @throws E not really throws, but helps maintain checked exception safety
     */
    public static <T, R, E extends Exception> Function<T, R> rethrowFunction(
            final FunctionWithExceptions<T, R, E> function) throws E {
        return t -> {
            try {
                return function.apply(t);
            } catch (final Exception exception) {
                throwAsUnchecked(exception);
                return null;
            }
        };
    }

    // maybe it's a better alternative because exception not re-thrown
    @SuppressWarnings("unchecked")
    public static <T, R, E extends Exception> Function<T, R> rethrowFunction2(
            final FunctionWithExceptions<T, R, E> function) throws E {
        return ((FunctionWithExceptions<T, R, RuntimeException>) function)::apply;
    }

    public static <T, U, R, E extends Exception> BiFunction<T, U, R> rethrowBiFunction(
            final BiFunctionWithExceptions<T, U, R, E> biFunction) throws E {
        return (t, u) -> {
            try {
                return biFunction.apply(t, u);
            } catch (final Exception exception) {
                throwAsUnchecked(exception);
                return null;
            }
        };
    }

    public static <T, E extends Exception> Comparator<T> rethrowComparator(
            final BiFunctionWithExceptions<T, T, Integer, E> biFunction) throws E {
        return (t, u) -> {
            try {
                return biFunction.apply(t, u);
            } catch (final Exception exception) {
                throwAsUnchecked(exception);
                return 0;
            }
        };
    }

    public static <T, E extends Exception> ToIntFunction<T> rethrowToIntFunction(
            final FunctionWithExceptions<T, Integer, E> toIntFunction) throws E {
        return t -> {
            try {
                return toIntFunction.apply(t);
            } catch (final Exception exception) {
                throwAsUnchecked(exception);
                return 0;
            }
        };
    }

    /**
     * ex: {@code rethrowSupplier(() -> new StringJoiner(new String(new byte[]{77, 97, 114, 107},
     * "UTF-8"))),}
     *
     * @param <T> the type of the supplier output
     * @param <E> the type of the exception
     * @param function the supplier
     * @return a sneaky-throwing Supplier
     * @throws E not really throws, but helps maintain checked exception safety
     */
    public static <T, E extends Exception> Supplier<T> rethrowSupplier(
            final SupplierWithExceptions<T, E> function) throws E {
        return () -> {
            try {
                return function.get();
            } catch (final Exception exception) {
                throw throwAsUnchecked(exception);
            }
        };
    }

    @SuppressWarnings("unchecked")
    public static <T, E extends Exception> Supplier<T> rethrowSupplier2(
            final SupplierWithExceptions<T, E> function) throws E {
        return ((SupplierWithExceptions<T, RuntimeException>) function)::get;
    }

    /**
     * ex: {@code uncheck(() -> Class.forName("xxx"));}
     * 
     * @param <E> the type of the exception
     * @param t the runnable
     */
    public static <E extends Exception> void uncheck(final RunnableWithExceptions<E> t) {
        try {
            t.run();
        } catch (final Exception exception) {
            throw throwAsUnchecked(exception);
        }
    }

    /**
     * ex: {@code uncheck(() -> Class.forName("xxx"));}
     *
     * @param <R> the type of results supplied by this supplier
     * @param <E> the type of the exception
     * @param supplier the supplier argument
     * @return the supplier result
     */
    public static <R, E extends Exception> R uncheck(final SupplierWithExceptions<R, E> supplier) {
        try {
            return supplier.get();
        } catch (final Exception exception) {
            throwAsUnchecked(exception);
            return null;
        }
    }

    /**
     * ex: {@code uncheck(Class::forName, "xxx");}
     *
     * @param <T> the type of the input to the function
     * @param <R> the type of the result of the function
     * @param <E> the type of the exception
     * @param function function to apply
     * @param t the function argument
     * @return the function result
     */
    public static <T, R, E extends Exception> R uncheck(
            final FunctionWithExceptions<T, R, E> function,
            final T t) {
        try {
            return function.apply(t);
        } catch (final Exception exception) {
            throw throwAsUnchecked(exception);
        }
    }

    @SuppressWarnings("unchecked")
    private static <E extends Throwable> RuntimeException throwAsUnchecked(
            final Exception exception) throws E {
        throw (E) exception;
    }

    /**
     * Put entries to a map by specific entry value property.
     *
     * @param entries
     * @param keyMapper
     * @return The map.
     */
    public static < //
        EV, // NOSONAR
        K,
        EK // NOSONAR
    > Map<K, Map.Entry<EK, EV>> byEntryValProp(
            final Collection<Map.Entry<EK, EV>> entries,
            final Function<? super EV, ? extends K> keyMapper) {
        return byProperty(entries, s -> keyMapper.apply(s.getValue()));
    }

    /**
     * Put beans to a map by specific bean property.
     *
     * @param beans
     * @param keyMapper
     * @return
     */
    public static <T, K> Map<K, T> byProperty(
            final Collection<T> beans,
            final Function<? super T, ? extends K> keyMapper) {
        return beans.stream().filter(s -> keyMapper.apply(s) != null).collect(
            Collectors.toMap(keyMapper, Function.identity(), (p1, p2) -> p1));
    }
}
