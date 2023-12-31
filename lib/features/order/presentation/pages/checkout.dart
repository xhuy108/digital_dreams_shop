import 'package:digital_dreams_shop/config/routes/route_names.dart';
import 'package:digital_dreams_shop/config/theme/colors.dart';
import 'package:digital_dreams_shop/config/theme/media_resource.dart';
import 'package:digital_dreams_shop/core/common/widgets/custom_button.dart';
import 'package:digital_dreams_shop/core/common/widgets/status_dialog.dart';
import 'package:digital_dreams_shop/core/constraints/constraints.dart';
import 'package:digital_dreams_shop/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:digital_dreams_shop/features/home/presentation/widgets/coupon_item.dart';
import 'package:digital_dreams_shop/features/order/data/models/address_model.dart';
import 'package:digital_dreams_shop/features/order/data/models/order_model.dart';
import 'package:digital_dreams_shop/features/order/presentation/cubit/order_coupon_cubit.dart';
import 'package:digital_dreams_shop/features/order/presentation/cubit/order_cubit.dart';
import 'package:digital_dreams_shop/features/order/presentation/widgets/order_coupon_item.dart';
import 'package:digital_dreams_shop/features/order/presentation/widgets/payment_button.dart';
import 'package:digital_dreams_shop/features/order/presentation/cubit/address_cubit.dart';
import 'package:digital_dreams_shop/features/order/presentation/widgets/checkout_item.dart';
import 'package:digital_dreams_shop/features/cart/presentation/widgets/address_information_title.dart';
import 'package:digital_dreams_shop/features/home/presentation/widgets/custom_suffix_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;
import 'dart:convert';

enum PaymentMethodEnum { cashOnDelivery, stripe }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cart});

  final String cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethodEnum paymentMethod = PaymentMethodEnum.cashOnDelivery;
  Map<String, dynamic>? paymentIntent;
  int shipCost = 30000;
  AddressModel? address;
  int? discountValue;

  void makePayment(int amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'VN',
            currencyCode: 'vnd',
            testEnv: true,
          ),
          style: ThemeMode.dark,
          merchantDisplayName: 'Example Inc.',
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: AppColor.primary,
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: AppColor.primary,
                  text: AppColor.textLight,
                ),
              ),
            ),
          ),
        ),
      );
      displayPaymentSheet();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      if (mounted) {
        if (widget.cart == 'cart') {
          BlocProvider.of<CartCubit>(context).emptyCartItem();
        }
        BlocProvider.of<OrderCubit>(context).emptyOrder();
        shipCost = 0;
        discountValue = 0;
        showDialog(
          context: context,
          builder: (ctx) {
            return const StatusDialog();
          },
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  createPaymentIntent(int amount) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount.toString(),
        'currency': 'vnd',
      };

      http.Response response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $kStripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = (context.watch<CartCubit>().state as CartLoaded).cart;
    final order = context.watch<OrderCubit>().state;
    final coupons = context.watch<OrderCouponCubit>().state.coupons;
    var totalOrderPrice = order.totalOrderPrice + shipCost;

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Subtotal: ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColor.checkOutText,
                  ),
                ),
                const Spacer(),
                Text(
                  currency.format(order.totalOrderPrice).toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColor.text,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Text(
                    'Shipping fee: ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColor.checkOutText,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    currency.format(shipCost).toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColor.text,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Text(
                    'Subtotal',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.text,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    currency
                        .format(order.totalOrderPrice + shipCost)
                        .toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.text,
                    ),
                  ),
                ],
              ),
            ),
            discountValue != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Text(
                          'Discount value',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.checkOutText,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          currency.format(discountValue).toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.text,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  Text(
                    discountValue == null
                        ? 'Total: ${currency.format(totalOrderPrice).toString()}'
                        : 'Total: ${currency.format(totalOrderPrice - discountValue!).toString()}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColor.text,
                    ),
                  ),
                  const Spacer(),
                  CustomButton(
                    width: 65,
                    height: 50,
                    text: 'Pay Now',
                    onPressed: () {
                      if (address == null) {
                        showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 24,
                                horizontal: 18,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    MediaResource.error,
                                    width: 80,
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Text(
                                    'Error!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    'Please choose an address!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF666666),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.add_location_rounded,
                                      color: AppColor.textLight,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 24,
                                      ),
                                    ),
                                    onPressed: () {
                                      context.pop();
                                      context.pushNamed(RouteNames.address);
                                    },
                                    label: Text(
                                      'Choose address',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppColor.textLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        return;
                      }
                      if (paymentMethod == PaymentMethodEnum.cashOnDelivery) {
                        if (widget.cart == 'cart') {
                          BlocProvider.of<CartCubit>(context).emptyCartItem();
                        }
                        BlocProvider.of<OrderCubit>(context).emptyOrder();
                        final newOrder = OrderModel(
                          items: order.orderItems,
                          shippingAddress: address!,
                          paymentMethod: 'Cash On Delivery',
                          shippingPrice: shipCost,
                        );
                        discountValue == null
                            ? context.read<OrderCubit>().createOrder(newOrder)
                            : context.read<OrderCubit>().createDiscountOrder(
                                  newOrder,
                                  order.totalOrderPrice - discountValue!,
                                );
                        setState(() {
                          shipCost = 0;
                          discountValue = 0;
                        });
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return const StatusDialog();
                          },
                        );
                      }
                      if (paymentMethod == PaymentMethodEnum.stripe) {
                        makePayment(order.totalOrderPrice + shipCost);
                        final newOrder = OrderModel(
                          items: order.orderItems,
                          shippingAddress: address!,
                          paymentMethod: 'Stripe',
                          shippingPrice: shipCost,
                        );
                        //context.read<OrderCubit>().createOrder(newOrder);
                        discountValue == null
                            ? context.read<OrderCubit>().createOrder(newOrder)
                            : context.read<OrderCubit>().createDiscountOrder(
                                  newOrder,
                                  order.totalOrderPrice - discountValue!,
                                );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 30,
            right: 30,
            top: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 45,
                    width: 45,
                    child: IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: SvgPicture.asset(MediaResource.arrowBack),
                      style: IconButton.styleFrom(
                          backgroundColor: AppColor.primary, elevation: 2),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Checkout',
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(
                    width: 61,
                  ),
                  Row(
                    children: [
                      CustomSuffixIcon(
                        svgImg: MediaResource.message,
                        onPressed: () {},
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      badges.Badge(
                        position: badges.BadgePosition.topEnd(top: -8, end: -5),
                        badgeContent: Text(
                          cart.cartTotalQuantity.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColor.textLight,
                          ),
                        ),
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: AppColor.primary,
                          padding: EdgeInsets.all(5),
                        ),
                        child: CustomSuffixIcon(
                          svgImg: MediaResource.cart,
                          onPressed: () {
                            context.pushNamed(RouteNames.cart);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: AppColor.background,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFE3DBDD).withOpacity(0.25),
                                  offset: const Offset(5, 5),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 18,
                              ),
                              child: BlocBuilder<AddressCubit, AddressState>(
                                builder: (context, state) {
                                  if (state is AddressLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (state is AddressFail) {
                                    return Center(
                                      child: Text(state.message),
                                    );
                                  }
                                  if (state is! AddressesLoaded) {
                                    return const Center(
                                      child: Text('Something went wrong!'),
                                    );
                                  }
                                  if (state.addresses.isEmpty) {
                                    return const Text('No address yet!');
                                  }

                                  address = AddressModel(
                                    id: state.addresses[0].id,
                                    customer: state.addresses[0].customer,
                                    phoneNumber: state.addresses[0].phoneNumber,
                                    detailedAddress:
                                        state.addresses[0].detailedAddress,
                                    district: state.addresses[0].district,
                                    city: state.addresses[0].city,
                                    country: state.addresses[0].country,
                                  );

                                  return Column(
                                    children: [
                                      AddressInformationTitle(
                                        title: 'Customer: ',
                                        value: state.addresses[0].customer,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: AddressInformationTitle(
                                          title: 'Phone number: ',
                                          value: state.addresses[0].phoneNumber,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: AddressInformationTitle(
                                          title: 'Street: ',
                                          value: state
                                              .addresses[0].detailedAddress,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: AddressInformationTitle(
                                          title: 'District: ',
                                          value: state.addresses[0].district,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: AddressInformationTitle(
                                          title: 'City: ',
                                          value: state.addresses[0].city,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: AddressInformationTitle(
                                          title: 'Country: ',
                                          value: state.addresses[0].country,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 8,
                            child: IconButton(
                              onPressed: () async {
                                await context.pushNamed(RouteNames.address);
                                setState(() {});
                              },
                              icon: SvgPicture.asset(
                                MediaResource.pen,
                                width: 16,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColor.background,
                                elevation: 2,
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Payment Method',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.text,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: PaymentButton(
                          icon: MediaResource.cash,
                          content: 'Cash on Delivery',
                          value: PaymentMethodEnum.cashOnDelivery,
                          groupValue: paymentMethod,
                          onChanged: (value) {
                            setState(() {
                              paymentMethod = value!;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: PaymentButton(
                          icon: MediaResource.stripe,
                          content: 'Stripe',
                          value: PaymentMethodEnum.stripe,
                          groupValue: paymentMethod,
                          onChanged: (value) {
                            setState(() {
                              paymentMethod = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Home Delivery',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.text,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: order.orderItems.length,
                        itemBuilder: (ctx, index) => CheckoutItem(
                          product: order.orderItems[index].product,
                          quantity: order.orderItems[index].quantity,
                          imageCover:
                              order.orderItems[index].product.imageCover,
                        ),
                      ),
                      coupons.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Coupons',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.text,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                SizedBox(
                                  height: 180,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: coupons.length,
                                    itemBuilder: (ctx, index) =>
                                        OrderCouponItem(
                                      coupon: coupons[index],
                                      onTap: () {
                                        setState(() {
                                          discountValue = order
                                                  .totalOrderPrice *
                                              coupons[index].discountValue ~/
                                              100;
                                          totalOrderPrice =
                                              totalOrderPrice - discountValue!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
