import 'package:realm_common/realm_common.dart';

const _config = GeneratorConfig(ctorStyle: CtorStyle.allNamed);

const realm = RealmModel.using(
  baseType: ObjectType.realmObject,
  generatorConfig: _config,
);

const realmEmbedded = RealmModel.using(
  baseType: ObjectType.embeddedObject,
  generatorConfig: _config,
);
