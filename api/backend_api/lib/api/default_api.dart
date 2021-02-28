part of openapi.api;


class DefaultApi {
  final DefaultApiDelegate apiDelegate;
  DefaultApi(ApiClient apiClient) : assert(apiClient != null), apiDelegate = DefaultApiDelegate(apiClient);


  /// 
  ///
  /// Returns all categories available
    Future<List<Category>> 
  categoriesGet({Options options}) async {

    final response = await apiDelegate.categoriesGet( options: options, );

    if(response.statusCode >= 400) {
      throw ApiException(response.statusCode, await decodeBodyBytes(response));
    } else {
      return await apiDelegate.categoriesGet_decode(response);
    }
  }

  /// 
  ///
  /// Returns all categories available
  /// 
  ///
  /// Returns information about a specific category
    Future<Category> 
  categoriesIdGet(int id, {Options options}) async {

    final response = await apiDelegate.categoriesIdGet(id,  options: options, );

    if(response.statusCode >= 400) {
      throw ApiException(response.statusCode, await decodeBodyBytes(response));
    } else {
      return await apiDelegate.categoriesIdGet_decode(response);
    }
  }

  /// 
  ///
  /// Returns information about a specific category
  /// 
  ///
  /// Returns all subscriptions for this user
    Future<List<Subscription>> 
  subscriptionsGet({Options options, DateTime startsAt, DateTime endsAt, int category, DateTime nextRecurrence, DateTime recursBefore }) async {

    final response = await apiDelegate.subscriptionsGet( options: options, startsAt: startsAt, endsAt: endsAt, category: category, nextRecurrence: nextRecurrence, recursBefore: recursBefore);

    if(response.statusCode >= 400) {
      throw ApiException(response.statusCode, await decodeBodyBytes(response));
    } else {
      return await apiDelegate.subscriptionsGet_decode(response);
    }
  }

  /// 
  ///
  /// Returns all subscriptions for this user
  /// 
  ///
  /// Deletes a specific subscription
    Future 
  subscriptionsIdDelete(int id, {Options options}) async {

    final response = await apiDelegate.subscriptionsIdDelete(id,  options: options, );

    if(response.statusCode >= 400) {
      throw ApiException(response.statusCode, await decodeBodyBytes(response));
    } else {
      return await apiDelegate.subscriptionsIdDelete_decode(response);
    }
  }

  /// 
  ///
  /// Deletes a specific subscription
  /// 
  ///
  /// Returns information about a specific subscription
    Future<Subscription> 
  subscriptionsIdGet(int id, {Options options}) async {

    final response = await apiDelegate.subscriptionsIdGet(id,  options: options, );

    if(response.statusCode >= 400) {
      throw ApiException(response.statusCode, await decodeBodyBytes(response));
    } else {
      return await apiDelegate.subscriptionsIdGet_decode(response);
    }
  }

  /// 
  ///
  /// Returns information about a specific subscription
  /// 
  ///
  /// Edits a specific subscription
    Future 
  subscriptionsIdPatch(int id, {Options options}) async {

    final response = await apiDelegate.subscriptionsIdPatch(id,  options: options, );

    if(response.statusCode >= 400) {
      throw ApiException(response.statusCode, await decodeBodyBytes(response));
    } else {
      return await apiDelegate.subscriptionsIdPatch_decode(response);
    }
  }

  /// 
  ///
  /// Edits a specific subscription
  /// 
  ///
  /// Creates a single subscription
    Future 
  subscriptionsPost({Options options, DateTime startsAt, DateTime endsAt, int category, DateTime nextRecurrence, DateTime recursBefore, Subscription subscription }) async {

    final response = await apiDelegate.subscriptionsPost( options: options, startsAt: startsAt, endsAt: endsAt, category: category, nextRecurrence: nextRecurrence, recursBefore: recursBefore, subscription: subscription);

    if(response.statusCode >= 400) {
      throw ApiException(response.statusCode, await decodeBodyBytes(response));
    } else {
      return await apiDelegate.subscriptionsPost_decode(response);
    }
  }

  /// 
  ///
  /// Creates a single subscription
}


  class DefaultApiDelegate {
  final ApiClient apiClient;

DefaultApiDelegate(this.apiClient) : assert(apiClient != null);

    Future<ApiResponse>
  categoriesGet({Options options}) async {
    Object postBody;

    // verify required params are set

    // create path and map variables
    final __path = '/categories/';

    // query params
    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{}..addAll(options?.headers?.cast<String, String>() ?? {});
    if(headerParams['Accept'] == null) {
      // we only want to accept this format as we can parse it
      headerParams['Accept'] = 'application/json';
    }


    final authNames = <String>[];
    final opt = options ?? Options();

      final contentTypes = [];

      if (contentTypes.isNotEmpty && headerParams['Content-Type'] == null) {
      headerParams['Content-Type'] = contentTypes[0];
      }
      if (postBody != null) {
      postBody = LocalApiClient.serialize(postBody);
      }

    opt.headers = headerParams;
    opt.method = 'GET';

    return await apiClient.invokeAPI(__path, queryParams, postBody, authNames, opt);
    }

    Future<List<Category>> 
  categoriesGet_decode(ApiResponse response) async {
    if(response.body != null) {
          return (LocalApiClient.deserializeFromString(await decodeBodyBytes(response), 'List<Category>') as List).map((item) => item as Category).toList();
    }

    return null;
    }
    Future<ApiResponse>
  categoriesIdGet(int id, {Options options}) async {
    Object postBody;

    // verify required params are set
        if(id == null) {
        throw ApiException(400, 'Missing required param: id');
        }

    // create path and map variables
    final __path = '/categories/{id}/'.replaceAll('{' + 'id' + '}', id.toString());

    // query params
    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{}..addAll(options?.headers?.cast<String, String>() ?? {});
    if(headerParams['Accept'] == null) {
      // we only want to accept this format as we can parse it
      headerParams['Accept'] = 'application/json';
    }


    final authNames = <String>[];
    final opt = options ?? Options();

      final contentTypes = [];

      if (contentTypes.isNotEmpty && headerParams['Content-Type'] == null) {
      headerParams['Content-Type'] = contentTypes[0];
      }
      if (postBody != null) {
      postBody = LocalApiClient.serialize(postBody);
      }

    opt.headers = headerParams;
    opt.method = 'GET';

    return await apiClient.invokeAPI(__path, queryParams, postBody, authNames, opt);
    }

    Future<Category> 
  categoriesIdGet_decode(ApiResponse response) async {
    if(response.body != null) {
            return LocalApiClient.deserializeFromString(await decodeBodyBytes(response), 'Category') as Category;
    }

    return null;
    }
    Future<ApiResponse>
  subscriptionsGet({Options options, DateTime startsAt, DateTime endsAt, int category, DateTime nextRecurrence, DateTime recursBefore }) async {
    Object postBody;

    // verify required params are set

    // create path and map variables
    final __path = '/subscriptions/';

    // query params
    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{}..addAll(options?.headers?.cast<String, String>() ?? {});
    if(headerParams['Accept'] == null) {
      // we only want to accept this format as we can parse it
      headerParams['Accept'] = 'application/json';
    }

        if(startsAt != null) {
      queryParams.addAll(convertParametersForCollectionFormat(LocalApiClient.parameterToString, '', 'starts_at', startsAt));
        }
        if(endsAt != null) {
      queryParams.addAll(convertParametersForCollectionFormat(LocalApiClient.parameterToString, '', 'ends_at', endsAt));
        }
        if(category != null) {
      queryParams.addAll(convertParametersForCollectionFormat(LocalApiClient.parameterToString, '', 'category', category));
        }
        if(nextRecurrence != null) {
      queryParams.addAll(convertParametersForCollectionFormat(LocalApiClient.parameterToString, '', 'next_recurrence', nextRecurrence));
        }
        if(recursBefore != null) {
      queryParams.addAll(convertParametersForCollectionFormat(LocalApiClient.parameterToString, '', 'recurs_before', recursBefore));
        }

    final authNames = <String>[];
    final opt = options ?? Options();

      final contentTypes = [];

      if (contentTypes.isNotEmpty && headerParams['Content-Type'] == null) {
      headerParams['Content-Type'] = contentTypes[0];
      }
      if (postBody != null) {
      postBody = LocalApiClient.serialize(postBody);
      }

    opt.headers = headerParams;
    opt.method = 'GET';

    return await apiClient.invokeAPI(__path, queryParams, postBody, authNames, opt);
    }

    Future<List<Subscription>> 
  subscriptionsGet_decode(ApiResponse response) async {
    if(response.body != null) {
          return (LocalApiClient.deserializeFromString(await decodeBodyBytes(response), 'List<Subscription>') as List).map((item) => item as Subscription).toList();
    }

    return null;
    }
    Future<ApiResponse>
  subscriptionsIdDelete(int id, {Options options}) async {
    Object postBody;

    // verify required params are set
        if(id == null) {
        throw ApiException(400, 'Missing required param: id');
        }

    // create path and map variables
    final __path = '/subscriptions/{id}/'.replaceAll('{' + 'id' + '}', id.toString());

    // query params
    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{}..addAll(options?.headers?.cast<String, String>() ?? {});
    if(headerParams['Accept'] == null) {
      // we only want to accept this format as we can parse it
      headerParams['Accept'] = 'application/json';
    }


    final authNames = <String>[];
    final opt = options ?? Options();

      final contentTypes = [];

      if (contentTypes.isNotEmpty && headerParams['Content-Type'] == null) {
      headerParams['Content-Type'] = contentTypes[0];
      }
      if (postBody != null) {
      postBody = LocalApiClient.serialize(postBody);
      }

    opt.headers = headerParams;
    opt.method = 'DELETE';

    return await apiClient.invokeAPI(__path, queryParams, postBody, authNames, opt);
    }

    Future 
  subscriptionsIdDelete_decode(ApiResponse response) async {
    if(response.body != null) {
    }

    return;
    }
    Future<ApiResponse>
  subscriptionsIdGet(int id, {Options options}) async {
    Object postBody;

    // verify required params are set
        if(id == null) {
        throw ApiException(400, 'Missing required param: id');
        }

    // create path and map variables
    final __path = '/subscriptions/{id}/'.replaceAll('{' + 'id' + '}', id.toString());

    // query params
    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{}..addAll(options?.headers?.cast<String, String>() ?? {});
    if(headerParams['Accept'] == null) {
      // we only want to accept this format as we can parse it
      headerParams['Accept'] = 'application/json';
    }


    final authNames = <String>[];
    final opt = options ?? Options();

      final contentTypes = [];

      if (contentTypes.isNotEmpty && headerParams['Content-Type'] == null) {
      headerParams['Content-Type'] = contentTypes[0];
      }
      if (postBody != null) {
      postBody = LocalApiClient.serialize(postBody);
      }

    opt.headers = headerParams;
    opt.method = 'GET';

    return await apiClient.invokeAPI(__path, queryParams, postBody, authNames, opt);
    }

    Future<Subscription> 
  subscriptionsIdGet_decode(ApiResponse response) async {
    if(response.body != null) {
            return LocalApiClient.deserializeFromString(await decodeBodyBytes(response), 'Subscription') as Subscription;
    }

    return null;
    }
    Future<ApiResponse>
  subscriptionsIdPatch(int id, {Options options}) async {
    Object postBody;

    // verify required params are set
        if(id == null) {
        throw ApiException(400, 'Missing required param: id');
        }

    // create path and map variables
    final __path = '/subscriptions/{id}/'.replaceAll('{' + 'id' + '}', id.toString());

    // query params
    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{}..addAll(options?.headers?.cast<String, String>() ?? {});
    if(headerParams['Accept'] == null) {
      // we only want to accept this format as we can parse it
      headerParams['Accept'] = 'application/json';
    }


    final authNames = <String>[];
    final opt = options ?? Options();

      final contentTypes = [];

      if (contentTypes.isNotEmpty && headerParams['Content-Type'] == null) {
      headerParams['Content-Type'] = contentTypes[0];
      }
      if (postBody != null) {
      postBody = LocalApiClient.serialize(postBody);
      }

    opt.headers = headerParams;
    opt.method = 'PATCH';

    return await apiClient.invokeAPI(__path, queryParams, postBody, authNames, opt);
    }

    Future 
  subscriptionsIdPatch_decode(ApiResponse response) async {
    if(response.body != null) {
    }

    return;
    }
    Future<ApiResponse>
  subscriptionsPost({Options options, DateTime startsAt, DateTime endsAt, int category, DateTime nextRecurrence, DateTime recursBefore, Subscription subscription }) async {
    Object postBody = subscription;

    // verify required params are set

    // create path and map variables
    final __path = '/subscriptions/';

    // query params
    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{}..addAll(options?.headers?.cast<String, String>() ?? {});
    if(headerParams['Accept'] == null) {
      // we only want to accept this format as we can parse it
      headerParams['Accept'] = 'application/json';
    }

        if(startsAt != null) {
      queryParams.addAll(convertParametersForCollectionFormat(LocalApiClient.parameterToString, '', 'starts_at', startsAt));
        }
        if(endsAt != null) {
      queryParams.addAll(convertParametersForCollectionFormat(LocalApiClient.parameterToString, '', 'ends_at', endsAt));
        }
        if(category != null) {
      queryParams.addAll(convertParametersForCollectionFormat(LocalApiClient.parameterToString, '', 'category', category));
        }
        if(nextRecurrence != null) {
      queryParams.addAll(convertParametersForCollectionFormat(LocalApiClient.parameterToString, '', 'next_recurrence', nextRecurrence));
        }
        if(recursBefore != null) {
      queryParams.addAll(convertParametersForCollectionFormat(LocalApiClient.parameterToString, '', 'recurs_before', recursBefore));
        }

    final authNames = <String>[];
    final opt = options ?? Options();

      final contentTypes = ['application/json'];

      if (contentTypes.isNotEmpty && headerParams['Content-Type'] == null) {
      headerParams['Content-Type'] = contentTypes[0];
      }
      if (postBody != null) {
      postBody = LocalApiClient.serialize(postBody);
      }

    opt.headers = headerParams;
    opt.method = 'POST';

    return await apiClient.invokeAPI(__path, queryParams, postBody, authNames, opt);
    }

    Future 
  subscriptionsPost_decode(ApiResponse response) async {
    if(response.body != null) {
    }

    return;
    }
  }


