import 'package:digital_dreams_shop/core/usecases/usecase.dart';
import 'package:digital_dreams_shop/core/utils/typdefs.dart';
import 'package:digital_dreams_shop/features/order/data/models/address_model.dart';
import 'package:digital_dreams_shop/features/order/domain/repositories/address_repository.dart';

class AddAddress extends UseCaseWithParams<void, AddressModel> {
  final AddressRepository repository;

  AddAddress(this.repository);

  @override
  ResultFuture<void> call(AddressModel params) {
    return repository.addAddress(params);
  }
}
