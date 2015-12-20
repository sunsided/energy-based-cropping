try

    NET.addAssembly('D:\dev\EigeneSources\ma\source\matlab\packages\MongoDB.Bson.2.2.0\lib\net45\MongoDB.Bson.dll');
    NET.addAssembly('D:\dev\EigeneSources\ma\source\matlab\packages\MongoDB.Driver.Core.2.2.0\lib\net45\MongoDB.Driver.Core.dll');
    NET.addAssembly('D:\dev\EigeneSources\ma\source\matlab\packages\MongoDB.Driver.2.2.0\lib\net45\MongoDB.Driver.dll');
   
catch e
    e.message
    if (isa(e,'NET.NetException'))
        e.ExceptionObject
        % e.ExceptionObject.LoaderExceptions(1).Message
    end
end

null = [];

client = MongoDB.Driver.MongoClient('mongodb://northbridge:27018');
database = client.GetDatabase('test');
collection = NET.invokeGenericMethod(database, 'GetCollection', {'MongoDB.Bson.BsonDocument'}, 'test', null);

filterBuilder = NET.createGeneric('MongoDB.Driver.FilterDefinitionBuilder', {'MongoDB.Bson.BsonDocument'});

%fieldDefinitionType = NET.GenericClass('MongoDB.Driver.FieldDefinition', 'MongoDB.Bson.BsonDocument', 'System.String');
fieldDefinition = NET.createGeneric('MongoDB.Driver.StringFieldDefinition', {'MongoDB.Bson.BsonDocument'}, 'test');
value = MongoDB.Bson.BsonString('lol');
filterDefinition = NET.createGeneric('MongoDB.Driver.SimpleFilterDefinition', {'MongoDB.Bson.BsonDocument', 'MongoDB.Bson.BsonValue'}, fieldDefinition, value);
%NET.invokeGenericMethod(filterBuilder, 'Eq', {fieldDefinitionType, 'System.String'}, fieldDefinition, 'lol');